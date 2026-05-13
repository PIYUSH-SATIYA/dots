local M = {}
local skip = {
  Normal = true,
  NormalNC = true,
  NormalFloat = true,
  FloatBorder = true,
  StatusLine = true,
  StatusLineNC = true,
  CursorLine = true,
  CursorLineNr = true,
  LineNr = true,
  WinSeparator = true,
  Visual = true,
  Pmenu = true,
  PmenuSel = true,
  PmenuSbar = true,
  PmenuThumb = true,
  SignColumn = true,
  DiagnosticError = true,
  DiagnosticWarn = true,
  DiagnosticInfo = true,
  DiagnosticHint = true,
  DiffAdd = true,
  DiffChange = true,
  DiffDelete = true,
  Directory = true,
  Identifier = true,
  Function = true,
  Keyword = true,
  String = true,
  Number = true,
  Type = true,
  Comment = true,
  Constant = true,
  Special = true,
  Operator = true,
  Delimiter = true,
  Title = true,
  Todo = true,
  Whitespace = true,
}
local patterns = {
  { ".*NormalNC$", "NormalNC" },
  { ".*NormalFloat$", "NormalFloat" },
  { ".*Float$", "NormalFloat" },
  { ".*FloatBorder$", "FloatBorder" },
  { ".*Border$", "FloatBorder" },
  { ".*WinSeparator$", "WinSeparator" },
  { ".*VertSplit$", "WinSeparator" },
  { ".*Separator$", "WinSeparator" },
  { ".*StatusLineNC$", "StatusLineNC" },
  { ".*StatusLine$", "StatusLine" },
  { ".*LineNr$", "LineNr" },
  { ".*CursorLineNr$", "CursorLineNr" },
  { ".*CursorLine$", "CursorLine" },
  { ".*Visual$", "Visual" },
  { ".*Selection$", "Visual" },
  { ".*Pmenu$", "Pmenu" },
  { ".*PmenuSel$", "PmenuSel" },
  { ".*PmenuSbar$", "PmenuSbar" },
  { ".*PmenuThumb$", "PmenuThumb" },
  { ".*Sign.*", "SignColumn" },
  { ".*Directory.*", "Directory" },
  { ".*FileName.*", "Normal" },
  { ".*FileIcon.*", "Identifier" },
  { ".*Indent.*", "Whitespace" },
  { ".*Whitespace.*", "Whitespace" },
  { ".*Git.*Add.*", "DiffAdd" },
  { ".*Git.*Change.*", "DiffChange" },
  { ".*Git.*Delete.*", "DiffDelete" },
  { ".*DiffAdd.*", "DiffAdd" },
  { ".*DiffChange.*", "DiffChange" },
  { ".*DiffDelete.*", "DiffDelete" },
  { ".*Diagnostic.*Error.*", "DiagnosticError" },
  { ".*Diagnostic.*Warn.*", "DiagnosticWarn" },
  { ".*Diagnostic.*Info.*", "DiagnosticInfo" },
  { ".*Diagnostic.*Hint.*", "DiagnosticHint" },
  { ".*Error.*", "DiagnosticError" },
  { ".*Warn.*", "DiagnosticWarn" },
  { ".*Info.*", "DiagnosticInfo" },
  { ".*Hint.*", "DiagnosticHint" },
  { ".*Title$", "Title" },
  { ".*Todo.*", "Todo" },
  { ".*Keyword.*", "Keyword" },
  { ".*Function.*", "Function" },
  { ".*Type.*", "Type" },
  { ".*String.*", "String" },
  { ".*Number.*", "Number" },
  { ".*Comment.*", "Comment" },
  { ".*Constant.*", "Constant" },
  { ".*Special.*", "Special" },
  { ".*Operator.*", "Operator" },
  { ".*Delimiter.*", "Delimiter" },
  { ".*Normal$", "Normal" },
}
local function link_group(name, target)
  if name == target or skip[name] then
    return true
  end
  vim.api.nvim_set_hl(0, name, { link = target })
  return true
end
function M.apply()
  local groups = vim.fn.getcompletion("", "highlight")
  for _, name in ipairs(groups) do
    for _, rule in ipairs(patterns) do
      local pat, target = rule[1], rule[2]
      if name:match(pat) then
        link_group(name, target)
        break
      end
    end
  end
end
function M.setup()
  if M._setup then
    return
  end
  M._setup = true
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("WalLinkHighlights", { clear = true }),
    callback = function()
      M.apply()
    end,
  })
end
return M
