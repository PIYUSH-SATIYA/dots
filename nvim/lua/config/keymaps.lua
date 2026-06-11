-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- for moving to start or end of a line in both insert and normal mode
-- Normal mode
vim.keymap.set("n", "<M-h>", "^", { desc = "Move to line start" })
vim.keymap.set("n", "<M-l>", "$", { desc = "Move to line end" })

-- Insert mode
vim.keymap.set("i", "<M-h>", "<Esc>^i", { desc = "Move to line start" })
vim.keymap.set("i", "<M-l>", "<Esc>$a", { desc = "Move to line end" })

-- to map jk in insert mode as escape key
vim.keymap.set("i", "kj", "<Esc>", { noremap = true, silent = true })

-- file manager
vim.keymap.set("n", "<leader>y", "<cmd>Yazi<cr>", { desc = "Open Yazi" })
