vim.opt.relativenumber = true

--[[
tabstop defines how many spaces a tab character 
(\t) visually represents in the editor.
It does not change the actual content of the file,
just how tabs appear.
]]
vim.opt.tabstop = 4

-- shiftwidth controls the number of spaces used for indentation
vim.opt.shiftwidth = 4

-- expandtab converts a tab press into spaces
vim.opt.expandtab = true

vim.opt.cursorline = true

require("config.lazy")

