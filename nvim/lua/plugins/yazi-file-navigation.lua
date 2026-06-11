return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    -- Pressing \y will open Yazi at the current file's directory
    {
      "<leader>y",
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    -- Pressing \yw will open Yazi at Neovim's current working directory
    {
      "<leader>yw",
      "<cmd>Yazi cwd<cr>",
      desc = "Open yazi at Neovim cwd",
    },
  },
  opts = {
    -- Optional configuration options
    open_for_directories = false, -- true if you want Yazi to override netrw completely
  },
}
