return {
  "folke/noice.nvim",
  opts = function(_, opts)
    opts.lsp.signature = {
      auto_open = { enabled = false },
      lsp_doc_border = true,
    }
  end,
}
