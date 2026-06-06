Name = "wallpaper"
NamePretty = "Wallpapers"
Icon = "image-x-generic"
Cache = false
HideFromProviderlist = false
Description = "Wallpaper picker"

local HOME = os.getenv("HOME")
local ROOT_DIR = HOME .. "/Pictures/wallpapers"
local STATE = "/tmp/walker-wallpaper-nav"
-- adjust if your open command differs:
local OPEN_CMD = "walker -t pywal --provider menus:wallpaper"

local function is_image(path)
	path = path:lower()
	return path:match("%.jpg$") or path:match("%.jpeg$") or path:match("%.png$") or path:match("%.webp$")
end

local function basename(path)
	return path:match("([^/]+)$")
end

local function sq(path)
	return "'" .. path:gsub("'", "'\\''") .. "'"
end

local function read_state()
	local f = io.open(STATE, "r")
	if f then
		local dir = f:read("*l")
		f:close()
		if dir and dir ~= "" then
			return dir
		end
	end
	return ROOT_DIR
end

-- shell cmd: write new dir to statefile, reopen walker
local function nav(path)
	return "printf '%s\\n' " .. sq(path) .. " > " .. STATE .. " && " .. OPEN_CMD .. " &"
end

function GetEntries()
	local current_dir = read_state()
	local entries = {}

	-- BACK
	if current_dir ~= ROOT_DIR then
		local parent = current_dir:match("(.+)/[^/]+$") or ROOT_DIR
		table.insert(entries, {
			Text = "    ..",
			Subtext = "↑ " .. basename(parent),
			Actions = { default = nav(parent) },
		})
	end

	-- DIRS
	local dh = io.popen("find " .. sq(current_dir) .. " -maxdepth 1 -mindepth 1 -type d | sort")
	if dh then
		for line in dh:lines() do
			table.insert(entries, {
				Text = "    " .. basename(line),
				Subtext = line,
				Actions = { default = nav(line) },
			})
		end
		dh:close()
	end

	-- IMAGES
	local fh = io.popen("find " .. sq(current_dir) .. " -maxdepth 1 -mindepth 1 -type f | sort")
	if fh then
		for line in fh:lines() do
			if is_image(line) then
				table.insert(entries, {
					Text = basename(line):gsub("%.%w+$", ""),
					Subtext = line,
					Value = line,
					Preview = line,
					PreviewType = "file",
					Actions = {
						default = "~/.config/hypr/scripts/wallpaper.sh " .. sq(line),
					},
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
