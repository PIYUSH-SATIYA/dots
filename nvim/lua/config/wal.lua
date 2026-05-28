local M = {}
local function read_wal()
  local path = vim.fn.expand("~/.cache/wal/colors.json")
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()
  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok or not data.colors then
    return nil
  end
  return data
end
local function clamp(v)
  if v < 0 then
    return 0
  end
  if v > 255 then
    return 255
  end
  return v
end
local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  if #hex == 3 then
    hex = hex:gsub(".", "%1%1")
  end
  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)
  return r, g, b
end
local function rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", clamp(r), clamp(g), clamp(b))
end
local function blend(fg, bg, alpha)
  local fr, fg2, fb = hex_to_rgb(fg)
  local br, bg2, bb = hex_to_rgb(bg)
  local r = math.floor((alpha * fr) + ((1 - alpha) * br) + 0.5)
  local g = math.floor((alpha * fg2) + ((1 - alpha) * bg2) + 0.5)
  local b = math.floor((alpha * fb) + ((1 - alpha) * bb) + 0.5)
  return rgb_to_hex(r, g, b)
end
function M.apply()
  local data = read_wal()
  if not data then
    return
  end
  local c = data.colors
  local sp = data.special or {}
  local fg = sp.foreground or c.color15
  local bg = sp.background or c.color0
  local visual_bg = blend(c.color8 or fg, bg, 0.35)
  local cursorline_bg = blend(c.color8 or fg, bg, 0.2)
  local float_bg = blend(bg, c.color0 or bg, 0.95)
  local border_fg = blend(c.color4 or fg, bg, 0.6)
  vim.api.nvim_set_hl(0, "Normal", { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "NormalNC", { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "NormalFloat", { fg = fg, bg = float_bg })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = border_fg, bg = float_bg })
  vim.api.nvim_set_hl(0, "CursorLine", { bg = cursorline_bg })
  vim.api.nvim_set_hl(0, "LineNr", { fg = c.color8 or fg })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = c.color3 or fg, bold = true })
  vim.api.nvim_set_hl(0, "Visual", { bg = visual_bg, nocombine = true })
  vim.api.nvim_set_hl(0, "Comment", { italic = true })
  vim.api.nvim_set_hl(0, "DiagnosticError", { fg = c.color1 })
  vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = c.color3 })
  vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = c.color4 })
  vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = c.color6 })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = c.color1 })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = c.color3 })
  vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = c.color2 })
  vim.api.nvim_set_hl(0, "GitSignsChange", { fg = c.color3 })
  vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = c.color1 })
  -- Neo-tree
  vim.api.nvim_set_hl(0, "NeoTreeNormal", { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "NeoTreeFileName", { fg = fg })
  vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { fg = c.color4 or fg, bold = true })
  vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = c.color4 or fg })
  vim.api.nvim_set_hl(0, "NeoTreeRootName", { fg = c.color6 or fg, bold = true })
  vim.api.nvim_set_hl(0, "NeoTreeGitAdded", { fg = c.color2 })
  vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = c.color3 })
  vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { fg = c.color1 })
  vim.api.nvim_set_hl(0, "NeoTreeIndentMarker", { fg = c.color8 })
  vim.api.nvim_set_hl(0, "NeoTreeExpander", { fg = c.color8 })
  vim.api.nvim_set_hl(0, "NeoTreeFileIcon", { fg = c.color6 })
  local ts_links = {
    ["@variable"] = "Identifier",
    ["@variable.builtin"] = "Special",
    ["@variable.member"] = "Identifier",
    ["@constant"] = "Constant",
    ["@constant.builtin"] = "Constant",
    ["@string"] = "String",
    ["@string.escape"] = "Special",
    ["@number"] = "Number",
    ["@boolean"] = "Boolean",
    ["@float"] = "Float",
    ["@function"] = "Function",
    ["@function.builtin"] = "Function",
    ["@function.call"] = "Function",
    ["@function.method"] = "Function",
    ["@constructor"] = "Type",
    ["@keyword"] = "Keyword",
    ["@keyword.return"] = "Keyword",
    ["@keyword.function"] = "Keyword",
    ["@keyword.operator"] = "Keyword",
    ["@keyword.import"] = "Include",
    ["@keyword.conditional"] = "Keyword",
    ["@keyword.repeat"] = "Keyword",
    ["@type"] = "Type",
    ["@type.builtin"] = "Type",
    ["@type.definition"] = "Type",
    ["@attribute"] = "PreProc",
    ["@operator"] = "Operator",
    ["@punctuation.bracket"] = "Delimiter",
    ["@punctuation.delimiter"] = "Delimiter",
    ["@punctuation.special"] = "Delimiter",
    ["@comment"] = "Comment",
    ["@comment.todo"] = "Todo",
    ["@tag"] = "Tag",
    ["@tag.attribute"] = "Identifier",
    ["@tag.delimiter"] = "Delimiter",
    ["@namespace"] = "Include",
    ["@module"] = "Include",
    ["@property"] = "Identifier",
    ["@label"] = "Label",
  }
  for capture, target in pairs(ts_links) do
    vim.api.nvim_set_hl(0, capture, { link = target })
  end
  local lsp_links = {
    ["@lsp.type.variable"] = "@variable",
    ["@lsp.type.parameter"] = "@variable",
    ["@lsp.type.property"] = "@property",
    ["@lsp.type.function"] = "@function",
    ["@lsp.type.method"] = "@function",
    ["@lsp.type.keyword"] = "@keyword",
    ["@lsp.type.type"] = "@type",
    ["@lsp.type.class"] = "@type",
    ["@lsp.type.interface"] = "@type",
    ["@lsp.type.namespace"] = "@namespace",
    ["@lsp.type.string"] = "@string",
    ["@lsp.type.number"] = "@number",
    ["@lsp.type.operator"] = "@operator",
    ["@lsp.type.comment"] = "@comment",
    ["@lsp.type.macro"] = "Macro",
    ["@lsp.type.enum"] = "@type",
    ["@lsp.type.enumMember"] = "@constant",
    ["@lsp.type.decorator"] = "Special",
    ["@lsp.type.typeParameter"] = "@type",
  }
  for capture, target in pairs(lsp_links) do
    vim.api.nvim_set_hl(0, capture, { link = target })
  end
  require("config.hl_links").apply()
end
function M.setup()
  if M._setup then
    return
  end
  M._setup = true
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("WalApply", { clear = true }),
    callback = function()
      M.apply()
    end,
  })
end
return M
