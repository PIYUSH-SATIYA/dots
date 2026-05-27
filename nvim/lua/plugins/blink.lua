return {
  "saghen/blink.cmp",
  dependencies = {
    "L3MON4D3/LuaSnip",
  },
  opts = {

    keymap = {
      -- Dropping the preset gives you full, explicit control.
      -- If you want to keep LazyVim defaults as a base, change to preset = "default"
      -- and only the keys you define here will be overridden.
      preset = "default",

      ["<C-Space>"] = {
        function(cmp)
          if cmp.is_visible() then
            cmp.hide()
          else
            cmp.show()
          end
        end,
      },

      -- ── Navigation ───────────────────────────────────────────────────────
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },

      -- ── Accept / dismiss ─────────────────────────────────────────────────
      -- CR also accepts (keeps muscle memory from other editors)
      -- ["<CR>"]      = { "accept", "fallback" },
      -- ── Trigger manually ─────────────────────────────────────────────────
      -- ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      -- ["<C-e>"]     = { "hide", "fallback" },

      -- ── Tab: the interesting one ─────────────────────────────────────────
      --
      ["<Tab>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.accept()
          end
        end,
        -- function()
        --   if vim.snippet and vim.snippet.active({ direction = 1 }) then
        --     vim.snippet.jump(1)
        --     return true
        --   end
        -- end,
        "fallback",
        -- No step 3. Let Neovim handle Tab natively → expandtab gives 2 spaces.
      },
      ["<M-k>"] = {
        function()
          local ls = require("luasnip")

          if ls.expand_or_jumpable() then
            ls.expand_or_jump()
            return true
          end
        end,
      },

      ["<M-j>"] = {
        function()
          local ls = require("luasnip")

          if ls.jumpable(-1) then
            ls.jump(-1)
            return true
          end
        end,
      },
      ["<S-Tab>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_prev()
          end
        end,
        function()
          if vim.snippet and vim.snippet.active({ direction = -1 }) then
            vim.snippet.jump(-1)
            return true
          end
        end,
        "fallback",
        -- No step 3. S-Tab has no native insert-mode meaning, so it just does nothing if above two fail.
      },
      --
      --
      --   ["<Tab>"] = {
      --     -- 1. Accept completion if menu is open
      --     function(cmp)
      --       if cmp.is_visible() then
      --         return cmp.accept()
      --       end
      --     end,
      --
      --     -- 2. Jump forward using Neovim's built-in snippet engine (vim.snippet)
      --     --    LazyVim on Neovim 0.10+ uses this, NOT LuaSnip.
      --     function()
      --       if vim.snippet and vim.snippet.active({ direction = 1 }) then
      --         vim.snippet.jump(1)
      --         return true
      --       end
      --     end,
      --
      --     -- 3. Fallback: explicit indent via <C-t>
      --     function()
      --       vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-t>", true, false, true), "n", false)
      --       return true
      --     end,
      --   },
      --
      --   ["<S-Tab>"] = {
      --     function(cmp)
      --       if cmp.is_visible() then
      --         return cmp.select_prev()
      --       end
      --     end,
      --     -- Jump backward in vim.snippet
      --     function()
      --       if vim.snippet and vim.snippet.active({ direction = -1 }) then
      --         vim.snippet.jump(-1)
      --         return true
      --       end
      --     end,
      --     -- Fallback: explicit unindent via <C-d>
      --     function()
      --       vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-d>", true, false, true), "n", false)
      --       return true
      --     end,
      --   },
      -- },
    },
    -- ── Auto-select first item (VS Code behaviour) ────────────────────────
    -- Without this, Tab would have nothing to accept until you press C-j once.
    completion = {
      list = {
        selection = {
          preselect = true, -- highlight item #1 the moment menu opens
          auto_insert = false, -- don't ghost-write it into the buffer yet
        },
      },
      -- Optional: show menu instantly with no delay (feels snappier)
      trigger = {
        show_on_insert_on_trigger_character = true,
      },
    },
    snippets = {
      preset = "luasnip",
    },

    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
      },
    },
  },
}
