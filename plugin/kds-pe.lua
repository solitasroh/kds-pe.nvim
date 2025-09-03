-- KDS PE Plugin Loader
-- 자동으로 KDS 프로젝트를 감지하고 플러그인 초기화

if vim.g.loaded_kds_pe then
    return
end
vim.g.loaded_kds_pe = 1

-- KDS 프로젝트 감지 및 자동 로드
local function auto_setup()
    local utils = require("kds-pe.utils")
    
    -- 현재 디렉토리가 KDS 프로젝트인지 확인
    if utils.is_kds_project() then
        require("kds-pe").setup()
    end
end

-- FileType 이벤트로 자동 감지
vim.api.nvim_create_autocmd({"BufEnter", "DirChanged"}, {
    callback = auto_setup,
    group = vim.api.nvim_create_augroup("KDS_PE_Auto", { clear = true }),
})

-- 수동 초기화 명령어
vim.api.nvim_create_user_command("KDSSetup", function()
    require("kds-pe").setup()
end, { desc = "Setup KDS PE plugin manually" })