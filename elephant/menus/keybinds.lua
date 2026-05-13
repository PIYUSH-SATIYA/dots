Name = "keybinds"
NamePretty = "Keybinds"

Icon = "preferences-desktop-keyboard"

Cache = false
HideFromProviderlist = false

Description = "Hyprland keybinds"

function trim(s)
	return s:match("^%s*(.-)%s*$")
end

function GetEntries()
	local entries = {}

	local handle = io.popen("grep -rh '^bind' ~/.config/hypr/binds/*.conf 2>/dev/null")

	if not handle then
		return {
			{
				Text = "Could not load binds",
			},
		}
	end

	for line in handle:lines() do
		local bind = line:match("^%s*bind[%w]*%s*=%s*(.+)$")

		if bind then
			local parts = {}

			for part in bind:gmatch("[^,]+") do
				table.insert(parts, trim(part))
			end

			if #parts >= 4 then
				local mods = parts[1]
				local key = parts[2]

				local description = nil
				local dispatcher = nil
				local command = nil

				-- bindd
				if line:match("^%s*bindd") then
					description = parts[3]
					dispatcher = parts[4]

					command = table.concat(parts, ", ", 5)
				else
					dispatcher = parts[3]

					command = table.concat(parts, ", ", 4)
				end

				table.insert(entries, {
					Text = mods .. " + " .. key,

					Subtext = (description and (description .. " -> ") or "") .. dispatcher .. " -> " .. command,

					Search = mods .. " " .. key .. " " .. (description or "") .. " " .. dispatcher .. " " .. command,

					Icon = "preferences-desktop-keyboard",
				})
			end
		end
	end

	handle:close()

	return entries
end
