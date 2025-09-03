-- KDS PE Utils
-- KDS 프로젝트 감지 및 경로 관리

local M = {}

-- KDS 프로젝트 여부 확인
function M.is_kds_project()
    local cwd = vim.fn.getcwd()
    local project_file = cwd .. "\\.project"
    
    -- .project 파일 존재 확인
    if vim.fn.filereadable(project_file) == 0 then
        return false
    end
    
    -- .project 파일에서 KDS 관련 내용 확인
    local ok, content = pcall(vim.fn.readfile, project_file)
    if not ok or not content then
        return false
    end
    
    for _, line in ipairs(content) do
        if string.find(line, "com.freescale") or 
           string.find(line, "org.eclipse.cdt") or
           string.find(line, "ProcessorExpert") then
            return true
        end
    end
    
    return false
end

-- 프로젝트 이름 추출
function M.get_project_name()
    local cwd = vim.fn.getcwd()
    local project_file = cwd .. "\\.project"
    
    if vim.fn.filereadable(project_file) == 0 then
        return vim.fn.fnamemodify(cwd, ":t")  -- 폴더명 사용
    end
    
    -- .project 파일에서 프로젝트명 추출
    local ok, content = pcall(vim.fn.readfile, project_file)
    if not ok or not content then
        return vim.fn.fnamemodify(cwd, ":t")
    end
    
    for _, line in ipairs(content) do
        local name = string.match(line, "<name>(.-)</name>")
        if name then
            return name
        end
    end
    
    return vim.fn.fnamemodify(cwd, ":t")  -- 폴더명 사용
end

-- KDS 설치 경로 감지
function M.detect_kds_path()
    -- 환경변수 확인
    local kds_home = vim.fn.getenv("KDS_HOME")
    if kds_home and kds_home ~= vim.NIL then
        local eclipse_path = kds_home .. "\\eclipse\\eclipsec.exe"
        if vim.fn.executable(eclipse_path) == 1 then
            return eclipse_path
        end
    end
    
    -- 기본 설치 경로들 확인
    local default_paths = {
        "C:\\Freescale\\KDS_v3\\eclipse\\eclipsec.exe",
        "C:\\NXP\\KDS_v3\\eclipse\\eclipsec.exe",
        "C:\\Program Files\\Freescale\\KDS_v3\\eclipse\\eclipsec.exe",
        "C:\\Program Files (x86)\\Freescale\\KDS_v3\\eclipse\\eclipsec.exe",
        "C:\\Freescale\\KDS_v2\\eclipse\\eclipsec.exe",
        "C:\\NXP\\KDS_v2\\eclipse\\eclipsec.exe"
    }
    
    for _, path in ipairs(default_paths) do
        if vim.fn.executable(path) == 1 then
            return path
        end
    end
    
    return nil
end

-- 워크스페이스 경로 감지 
function M.get_workspace_path()
    local cwd = vim.fn.getcwd()
    local workspace_dir = cwd
    
    -- .metadata 폴더를 찾아서 워크스페이스 경로 확인
    local current_dir = cwd
    while current_dir ~= vim.fn.fnamemodify(current_dir, ":h") do
        local metadata_path = current_dir .. "\\.metadata"
        if vim.fn.isdirectory(metadata_path) == 1 then
            workspace_dir = current_dir
            break
        end
        current_dir = vim.fn.fnamemodify(current_dir, ":h")
    end
    
    return workspace_dir
end

return M