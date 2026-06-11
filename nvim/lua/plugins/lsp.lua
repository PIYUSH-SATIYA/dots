return {
  {
    "neovim/nvim-lspconfig",

    opts = {
      inlay_hint = {
        enabled = true,
      },
      servers = {
        ["*"] = {
          capabilities = require("blink.cmp").get_lsp_capabilities(),
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",
              },
            },
          },
        },

        clangd = {
          keys = {
            { "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
          root_markers = {
            "compile_flags.txt",
            "compile_commands.json",
            "Makefile",
            ".git",
          },
          -- -- CRITICAL: Let blink.cmp manage capabilities for clangd snippet expansion
          -- capabilities = (function()
          --   local success, blink = pcall(require, "blink.cmp")
          --   if success then
          --     return blink.get_lsp_capabilities()
          --   else
          --     return {}
          --   end
          -- end)(),
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--query-driver=/usr/bin/g++",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
      },
    },
  },
}
