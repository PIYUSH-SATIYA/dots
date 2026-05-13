Name = "wallpaper"
NamePretty = "Wallpapers"
Icon = "image-x-generic"

Cache = false
HideFromProviderlist = false

Description = "Wallpaper picker"

Action = '~/.config/hypr/scripts/wallpaper.sh "%VALUE%"'

function GetEntries()
	local entries = {}

	local wallpaper_dir = os.getenv("HOME") .. "/Pictures/wallpapers"

	local cmd = "find '"
		.. wallpaper_dir
		.. "' -maxdepth 1 -type f \\( "
		.. "-iname '*.jpg' -o "
		.. "-iname '*.jpeg' -o "
		.. "-iname '*.png' -o "
		.. "-iname '*.webp' "
		.. "\\)"

	local handle = io.popen(cmd)

	if handle then
		for line in handle:lines() do
			local filename = line:match("([^/]+)$")

			table.insert(entries, {
				Text = filename,
				Subtext = line,
				Value = line,

				Preview = line,
				PreviewType = "file",
				-- Icon = line,
			})
		end

		handle:close()
	end

	return entries
end
