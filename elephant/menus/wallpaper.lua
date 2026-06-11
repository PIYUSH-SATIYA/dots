Name = "wallpaper"
NamePretty = "Wallpapers"
Icon = "image-x-generic"
Cache = false
HideFromProviderlist = false
Description = "Wallpaper picker"
Action = ""

local HOME = os.getenv("HOME")
local ROOT_DIR = HOME .. "/Pictures/wallpapers"
local STATE = "/tmp/walker-wallpaper-nav"

local function is_image(p)
	p = p:lower()
	return p:match("%.jpg$") or p:match("%.jpeg$") or p:match("%.png$") or p:match("%.webp$")
end
local function basename(p)
	return p:match("([^/]+)$")
end
local function sq(p)
	return "'" .. p:gsub("'", "'\\''") .. "'"
end

local function read_state()
	local f = io.open(STATE, "r")
	if f then
		local d = f:read("*l")
		f:close()
		if d and d ~= "" then
			return d
		end
	end
	return ROOT_DIR
end

local function set_dir(path)
	return "printf '%s\\n' " .. sq(path) .. " > " .. STATE
end

function GetEntries()
	local current_dir = read_state()
	local entries = {}

	local parent = current_dir:match("(.+)/[^/]+$") or ROOT_DIR
	local can_go_back = current_dir ~= ROOT_DIR

	if can_go_back then
		table.insert(entries, {
			Text = "    ..",
			Subtext = "↑ " .. basename(parent),
			Actions = { navigate = set_dir(parent), back = set_dir(parent) },
		})
	end

	local dh = io.popen("find " .. sq(current_dir) .. " -maxdepth 1 -mindepth 1 -type d | sort")
	if dh then
		for line in dh:lines() do
			local a = { navigate = set_dir(line) }
			if can_go_back then
				a.back = set_dir(parent)
			end
			table.insert(entries, {
				Text = "    " .. basename(line),
				Subtext = line,
				Actions = a,
			})
		end
		dh:close()
	end

	local fh = io.popen("find " .. sq(current_dir) .. " -maxdepth 1 -mindepth 1 -type f | sort")
	if fh then
		for line in fh:lines() do
			if is_image(line) then
				local a = { apply = "~/.config/theme-system/set-wallpaper.sh " .. sq(line) }
				if can_go_back then
					a.back = set_dir(parent)
				end
				table.insert(entries, {
					Text = basename(line):gsub("%.%w+$", ""),
					Subtext = line,
					Value = line,
					Preview = line,
					PreviewType = "file",
					Actions = a,
				})
			end
		end
		fh:close()
	end

	return entries
end

--
-- Name = "wallpaper"
-- NamePretty = "Wallpapers"
-- Icon = "image-x-generic"
--
-- Cache = false
-- HideFromProviderlist = false
--
-- Description = "Wallpaper picker"
--
-- Action = '~/.config/hypr/scripts/wallpaper.sh "%VALUE%"'
--
-- function GetEntries()
-- 	local entries = {}
--
-- 	local wallpaper_dir = os.getenv("HOME") .. "/Pictures/wallpapers"
--
-- 	local cmd = "find '"
-- 		.. wallpaper_dir
-- 		.. "' -maxdepth 1 -type f \\( "
-- 		.. "-iname '*.jpg' -o "
-- 		.. "-iname '*.jpeg' -o "
-- 		.. "-iname '*.png' -o "
-- 		.. "-iname '*.webp' "
-- 		.. "\\)"
--
-- 	local handle = io.popen(cmd)
--
-- 	if handle then
-- 		for line in handle:lines() do
-- 			local filename = line:match("([^/]+)$")
--
-- 			table.insert(entries, {
-- 				Text = filename,
-- 				Subtext = line,
-- 				Value = line,
--
-- 				Preview = line,
-- 				PreviewType = "file",
-- 				-- Icon = line,
-- 			})
-- 		end
--
-- 		handle:close()
-- 	end
--
-- 	return entries
-- end
