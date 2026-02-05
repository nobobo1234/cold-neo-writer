if vim.g.loaded_cold_neo then return end
vim.g.loaded_cold_neo = 1

local cold = require("cold_neo")

-- Command: :ColdStart 30
vim.api.nvim_create_user_command("ColdStart", cold.start_session, { nargs = 1 })

-- Emergency Command (Hidden knowledge for you): :ColdStop
vim.api.nvim_create_user_command("ColdStop", cold.stop_session, { nargs = 0 })
