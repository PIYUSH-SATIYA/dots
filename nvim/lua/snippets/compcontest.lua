local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("cpp", {

  s("compcontest", {
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
  }),
})
