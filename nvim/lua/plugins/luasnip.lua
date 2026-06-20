return {
  "L3MON4D3/LuaSnip",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local ls = require("luasnip")

    ls.config.set_config({
      region_check_events = "CursorMoved,CursorHold,InsertEnter",
      delete_check_events = "TextChanged,InsertLeave",
    })

    require("luasnip.loaders.from_lua").load({
      paths = { vim.fn.expand("~/.config/nvim/lua/snippets") },
    })
  end,
}
