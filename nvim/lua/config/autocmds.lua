-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "InsertLeave" }, {
  callback = function()
    if vim.bo.modified then
      vim.cmd("silent! wall")
    end
  end,
})

-- lsp keyword highlighting
--
vim.api.nvim_set_hl(0, "LspReferenceText", {})
vim.api.nvim_set_hl(0, "LspReferenceRead", {})
vim.api.nvim_set_hl(0, "LspReferenceWrite", {})

-- to disable auto adding comments in line below current coment line
--
vim.cmd("autocmd BufEnter * set formatoptions-=cro")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")


