-- KDS PE Build Plugin
-- 간단한 PE Generate 및 Build 기능 제공

local M = {}

local commands = require("kds-pe.commands")
local utils = require("kds-pe.utils")

function M.setup()
    -- KDS 프로젝트 여부 확인
    if not utils.is_kds_project() then
        return
    end

    -- 사용자 명령 등록
    vim.api.nvim_create_user_command("KDSPEGenerate", function()
        commands.pe_generate()
    end, { desc = "Generate PE code for KDS project" })

    vim.api.nvim_create_user_command("KDSBuild", function()
        commands.build()
    end, { desc = "Build KDS project (auto: make or headless)" })
    
    vim.api.nvim_create_user_command("KDSMakeBuild", function()
        commands.make_build()
    end, { desc = "Build KDS project with make" })
    
    vim.api.nvim_create_user_command("KDSHeadlessBuild", function()
        commands.headless_build()  
    end, { desc = "Build KDS project with Eclipse headless" })

    -- 키맵핑 설정
    vim.keymap.set("n", "<leader>kp", "<cmd>KDSPEGenerate<cr>", {
        desc = "KDS PE Generate",
        buffer = true
    })

    vim.keymap.set("n", "<leader>kb", "<cmd>KDSBuild<cr>", {
        desc = "KDS Build",
        buffer = true
    })

    -- print("KDS PE plugin loaded for project: " .. utils.get_project_name())
end

-- PE Generate 실행
function M.pe_generate()
    commands.pe_generate()
end

-- Build 실행
function M.build()
    commands.build()
end

return M
