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
        return vim.fn.fnamemodify(cwd, ":t") -- 폴더명 사용
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

    return vim.fn.fnamemodify(cwd, ":t") -- 폴더명 사용
end

-- KDS 설치 경로 감지
function M.detect_kds_path()
    -- 실행파일 우선순위: kinetis-design-studio.exe > eclipsec.exe > eclipse.exe
    local executable_names = {
        "kinetis-design-studio.exe", -- KDS 전용 실행파일
        "eclipsec.exe",              -- 헤드리스 모드 (권장)
        "eclipse.exe"                -- 일반 Eclipse 실행파일
    }

    -- 환경변수 KDS_HOME 확인
    local kds_home = vim.fn.getenv("KDS_HOME")
    if kds_home and kds_home ~= vim.NIL then
        -- KDS_HOME에서 실행파일 찾기
        for _, exe_name in ipairs(executable_names) do
            local exe_path = kds_home .. "\\eclipse\\" .. exe_name
            if vim.fn.executable(exe_path) == 1 then
                return exe_path
            end
            -- eclipse 폴더 없이 바로 있는 경우도 확인
            exe_path = kds_home .. "\\" .. exe_name
            if vim.fn.executable(exe_path) == 1 then
                return exe_path
            end
        end
    end

    -- 기본 설치 경로들 확인
    local base_paths = {
        "C:\\Freescale\\KDS_v3",
        "C:\\NXP\\KDS_v3",
        "C:\\Program Files\\Freescale\\KDS_v3",
        "C:\\Program Files (x86)\\Freescale\\KDS_v3",
        "C:\\Freescale\\KDS_v2",
        "C:\\NXP\\KDS_v2"
    }

    for _, base_path in ipairs(base_paths) do
        for _, exe_name in ipairs(executable_names) do
            -- eclipse 하위 폴더에서 찾기
            local exe_path = base_path .. "\\eclipse\\" .. exe_name
            if vim.fn.executable(exe_path) == 1 then
                return exe_path
            end
            -- 루트에서 찾기
            exe_path = base_path .. "\\" .. exe_name
            if vim.fn.executable(exe_path) == 1 then
                return exe_path
            end
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
