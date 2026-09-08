local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local events = require("luasnip.util.events")

ls.add_snippets("cpp", {
  s(
    "compcontest", -- context (just the trigger, unchanged)
    { -- nodes
      t({
        "#include <bits/stdc++.h>",
        "using namespace std;",
        "",
        "#define int long long",
        "",
        "const double PI = 3.14159265358979323846;",
        "",
        "void solve()",
        "{",
        "    ",
      }),
      i(1),
      t({
        "",
        "}",
        "",
        "signed main()",
        "{",
        "    ios::sync_with_stdio(false);",
        "    cin.tie(nullptr);",
        "",
        "#ifndef ONLINE_JUDGE",
        '    freopen("input.txt", "r", stdin);',
        '    freopen("output.txt", "w", stdout);',
        "#endif",
        "",
        "    int t;",
        "    cin >> t;",
        "",
        "    while (t--)",
        "    {",
        "        solve();",
        "    }",
        "",
        "    return 0;",
        "}",
      }),
    },
    {
      callbacks = {
        [1] = {
          [events.enter] = function()
            vim.defer_fn(function()
              if ls.session and ls.session.current_nodes then
                for buf, _ in pairs(ls.session.current_nodes) do
                  ls.unlink_current(buf)
                end
              end
            end, 0)
          end,
        },
      },
    }
  ),
})
