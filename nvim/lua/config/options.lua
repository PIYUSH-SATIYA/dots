-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- OPTIMIZED FOR SNAPPINESS
-- timeoutlen: was 1000ms, now 300ms (key sequences register faster)
vim.o.timeoutlen = 300
-- updatetime: was 200ms, now 50ms (faster LSP/diagnostic updates)
vim.o.updatetime = 50
vim.opt.relativenumber = true
vim.opt.wrap = true


