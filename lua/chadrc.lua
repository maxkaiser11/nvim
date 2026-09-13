-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
<<<<<<< HEAD
	theme = "everforest",
=======
	theme = "onedark",
>>>>>>> e1d04d4d84211068ed7edc31bdf6e15a3567f025
	transparency = true,

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- Using the snacks.nvim dashboard (see lua/plugins/snacks.lua) as the startup
-- screen, so NvChad's nvdash is kept off.
M.nvdash = { load_on_startup = false }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
