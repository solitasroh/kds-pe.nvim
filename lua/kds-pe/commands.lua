-- KDS PE Commands
-- PE Generate 및 Build 명령 실행

local M = {}
local utils = require("kds-pe.utils")

-- PE 코드 생성 실행
function M.pe_generate()
    -- KDS 프로젝트 확인
    if not utils.is_kds_project() then
        vim.notify("KDS 프로젝트가 아닙니다!", vim.log.levels.ERROR)
        return
    end


    local kds_path = utils.detect_kds_path()
    if not kds_path then
        vim.notify("KDS 설치를 찾을 수 없습니다! KDS_HOME 환경변수를 설정하거나 기본 경로에 설치하세요.", vim.log.levels.ERROR)
        return
    end

    local workspace = utils.get_workspace_path()
    local project_name = utils.get_project_name()

    -- PE Generate 명령어 구성 (직접 실행)
    local cmd = string.format(
        '"%s" -nosplash -application com.freescale.processorexpert.core.generator -data "%s" -project "%s" -consolelog',
        kds_path,
        workspace,
        project_name
    )

    vim.notify("PE Generate 시작: " .. project_name, vim.log.levels.INFO)

    -- ToggleTerm 사용 가능 여부 확인
    local ok, Terminal = pcall(require, 'toggleterm.terminal')
    if not ok then
        vim.notify("ToggleTerm 플러그인이 설치되어 있지 않습니다!", vim.log.levels.ERROR)
        return
    end
    Terminal = Terminal.Terminal
    local pe_term = Terminal:new({
        cmd = cmd,
        dir = workspace,
        direction = "horizontal",
        size = 20,
        close_on_exit = false,
        on_open = function(term)
            vim.cmd("startinsert!")
        end,
        on_exit = function(term, job, exit_code, name)
            if exit_code == 0 then
                vim.notify("PE Generate 완료!", vim.log.levels.INFO)
            else
                vim.notify("PE Generate 실패! (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
            end
        end,
    })

    pe_term:toggle()
end

-- 빌드 실행 (조건부: make 우선, headless 대안)
function M.build()
    -- KDS 프로젝트 확인
    if not utils.is_kds_project() then
        vim.notify("KDS 프로젝트가 아닙니다!", vim.log.levels.ERROR)
        return
    end

    -- make 빌드 가능한지 확인
    if utils.can_use_make_build() then
        M.make_build()
    else
        M.headless_build()
    end
end

-- make를 사용한 빌드
function M.make_build()
    local make_path = utils.detect_make_path()
    if not make_path then
        vim.notify("make 실행파일을 찾을 수 없습니다! Eclipse headless 빌드로 대안 실행...", vim.log.levels.WARN)
        M.headless_build()
        return
    end

    local project_name = utils.get_project_name()
    local cmd = string.format('"%s" -C Debug all', make_path)
    
    vim.notify("Make 빌드 시작: " .. project_name, vim.log.levels.INFO)

    -- ToggleTerm 사용 가능 여부 확인
    local ok, Terminal = pcall(require, 'toggleterm.terminal')
    if not ok then
        vim.notify("ToggleTerm 플러그인이 설치되어 있지 않습니다!", vim.log.levels.ERROR)
        return
    end
    Terminal = Terminal.Terminal
    local make_term = Terminal:new({
        cmd = cmd,
        dir = vim.fn.getcwd(),
        direction = "float",
        close_on_exit = false,
        on_open = function(term)
            vim.cmd("startinsert!")
        end,
        on_exit = function(term, job, exit_code, name)
            if exit_code == 0 then
                vim.notify("Make 빌드 완료!", vim.log.levels.INFO)
            else
                vim.notify("Make 빌드 실패! (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
            end
        end,
    })
    
    make_term:toggle()
end

-- Eclipse headless 빌드 (Debug 폴더 생성용 또는 대안)
function M.headless_build()
    local kds_path = utils.detect_kds_path()
    if not kds_path then
        vim.notify("KDS 설치를 찾을 수 없습니다! KDS_HOME 환경변수를 설정하거나 기본 경로에 설치하세요.", vim.log.levels.ERROR)
        return
    end

    local workspace = utils.get_workspace_path()
    local project_name = utils.get_project_name()

    -- 초기 빌드인지 확인
    if not utils.has_debug_folder() then
        vim.notify("첫 번째 빌드: Debug 폴더와 Makefile을 생성합니다...", vim.log.levels.INFO)
    end

    -- Build 명령어 구성 (직접 실행)
    local cmd = string.format(
        '"%s" -nosplash -application org.eclipse.cdt.managedbuilder.core.headlessbuild -build "%s" -data "%s" -consolelog',
        kds_path,
        project_name,
        workspace
    )

    vim.notify("Build 시작: " .. project_name, vim.log.levels.INFO)

    -- ToggleTerm 사용 가능 여부 확인
    local ok, Terminal = pcall(require, 'toggleterm.terminal')
    if not ok then
        vim.notify("ToggleTerm 플러그인이 설치되어 있지 않습니다!", vim.log.levels.ERROR)
        return
    end
    Terminal = Terminal.Terminal
    local build_term = Terminal:new({
        cmd = cmd,
        dir = workspace,
        direction = "float",
        close_on_exit = false,
        on_open = function(term)
            vim.cmd("startinsert!")
        end,
        on_exit = function(term, job, exit_code, name)
            if exit_code == 0 then
                vim.notify("Headless 빌드 완료!", vim.log.levels.INFO)
                -- 첫 번째 빌드 완료 후 make 사용 가능 안내
                if utils.can_use_make_build() then
                    vim.notify("다음 빌드부터는 더 빠른 make 빌드를 사용합니다!", vim.log.levels.INFO)
                end
                -- 빌드 성공 시 QuickFix 리스트 업데이트 (옵션)
                vim.cmd("copen")
            else
                vim.notify("Build 실패! (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
            end
        end,
    })

    build_term:toggle()
end

return M
