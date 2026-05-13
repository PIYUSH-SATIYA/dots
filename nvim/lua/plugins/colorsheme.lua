return {
  {
    "catppuccin/nvim",
    enabled = false,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "pywal16",
    },
  },
  {
    "uZer/pywal16.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("config.hl_links").setup()
      require("config.wal").setup()
      vim.cmd.colorscheme("pywal16")
      require("config.wal").apply()
    end,
  },
}

-- return {
--   -- Disable catppuccin entirely OR keep it but never call colorscheme
--   {
--     "catppuccin/nvim",
--     enabled = false, -- ← hard disable; it was the culprit
--   },
--
--   {
--     "uZer/pywal16.nvim",
--     lazy = false,
--     priority = 1000,
--     config = function()
--       require("config.hl_links").setup()
--       require("config.wal").setup()
--       vim.cmd.colorscheme("pywal16")
--       require("config.wal").apply()
--     end,
--     -- config = function()
--     --   -- ColorScheme autocmd must be registered BEFORE vim.cmd.colorscheme
--     --   -- so it fires on this very first load too
--     --   vim.api.nvim_create_autocmd("ColorScheme", {
--     --     group = vim.api.nvim_create_augroup("WalFixed", { clear = true }),
--     --     callback = function()
--     --       -- Visual re-pinned after every colorscheme application
--     --       vim.api.nvim_set_hl(0, "Visual", { bg = "#44475a", nocombine = true })
--     --     end,
--     --   })
--     --
--     --   vim.cmd.colorscheme("pywal16")
--     --   require("config.wal").load()
--     -- end,
--   },
-- }
