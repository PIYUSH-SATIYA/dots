return {
  "L3MON4D3/LuaSnip",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local ls = require("luasnip")

    require("luasnip.loaders.from_lua").load({
      paths = { vim.fn.expand("~/.config/nvim/lua/snippets") },
    })
  end,
}
