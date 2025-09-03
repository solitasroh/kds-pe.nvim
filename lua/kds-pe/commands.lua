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

    -- PE Generate 명령어 구성 (cmd 창 없이 직접 실행)
    local cmd = string.format(
        'powershell -WindowStyle Hidden -Command "& \'%s\' -nosplash -application com.freescale.processorexpert.core.generator -data \'%s\' -project \'%s\' -consolelog -debug -vmargs -Declipse.log.level=ALL 2>&1"',
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
        start_in_insert = false,  -- Normal 모드로 시작하여 출력 보기 편하게
        on_open = function(term)
            -- 터미널 설정 최적화 (stdout 전달에 최적화)
            pcall(vim.api.nvim_buf_set_option, term.bufnr, 'scrollback', 50000)
            pcall(vim.api.nvim_buf_set_option, term.bufnr, 'wrap', false)
            pcall(vim.api.nvim_buf_set_option, term.bufnr, 'number', false)
            pcall(vim.api.nvim_buf_set_option, term.bufnr, 'relativenumber', false)
            
            -- 실시간 스크롤을 위한 autocmd 설정
            vim.api.nvim_create_autocmd("BufWinEnter", {
                buffer = term.bufnr,
                callback = function()
                    vim.cmd("normal! G")  -- 버퍼 끝으로 이동
                end
            })
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

-- 빌드 실행
function M.build()
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

    -- Build 명령어 구성 (cmd 창 없이 직접 실행)
    local cmd = string.format(
        'powershell -WindowStyle Hidden -Command "& \'%s\' -nosplash -application org.eclipse.cdt.managedbuilder.core.headlessbuild -build \'%s\' -data \'%s\' -consolelog -debug -vmargs -Declipse.log.level=ALL 2>&1"',
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
        direction = "horizontal",
        size = 20,
        close_on_exit = false,
        start_in_insert = false,  -- Normal 모드로 시작하여 출력 보기 편하게
        on_open = function(term)
            -- 터미널 설정 최적화 (stdout 전달에 최적화)
            pcall(vim.api.nvim_buf_set_option, term.bufnr, 'scrollback', 50000)
            pcall(vim.api.nvim_buf_set_option, term.bufnr, 'wrap', false)
            pcall(vim.api.nvim_buf_set_option, term.bufnr, 'number', false)
            pcall(vim.api.nvim_buf_set_option, term.bufnr, 'relativenumber', false)
            
            -- 실시간 스크롤을 위한 autocmd 설정
            vim.api.nvim_create_autocmd("BufWinEnter", {
                buffer = term.bufnr,
                callback = function()
                    vim.cmd("normal! G")  -- 버퍼 끝으로 이동
                end
            })
        end,
        on_exit = function(term, job, exit_code, name)
            if exit_code == 0 then
                vim.notify("Build 완료!", vim.log.levels.INFO)
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
