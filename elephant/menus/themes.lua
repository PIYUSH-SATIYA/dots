Name = "themes"
NamePretty = "Themes"

function GetEntries()
	local entries = {}

	local theme_dir = os.getenv("HOME") .. "/.config/themes"

	local handle = io.popen("find '" .. theme_dir .. "' -name '*.json'")

	if handle then
		for file in handle:lines() do
			local name = file:match("([^/]+)%.json$")

			table.insert(entries, {
				Text = name,
				Actions = {
					activate = os.getenv("HOME") .. "/.config/theme-system/set-theme.sh " .. name,
				},
			})
		end

		handle:close()
	end

	table.insert(entries, {
		Text = "Wallpaper Theme",
		Actions = {
			activate = os.getenv("HOME") .. "/.config/theme-system/set-dynamic.sh",
		},
	})

	return entries
end
