Name = "keybinds"
NamePretty = "Keybinds"

Icon = "preferences-desktop-keyboard"

Cache = false
HideFromProviderlist = false

Description = "Hyprland keybinds"

------------------------------------------------------------
-- MODMASK MAPPING
------------------------------------------------------------

local mods = {
	[1] = "SHIFT",
	[4] = "CTRL",
	[8] = "ALT",
	[64] = "SUPER",
}

function modmask_to_string(mask)
	local result = {}

	for value, name in pairs(mods) do
		if math.floor(mask / value) % 2 == 1 then
			table.insert(result, name)
		end
	end

	return table.concat(result, " + ")
end

------------------------------------------------------------
-- MAIN
------------------------------------------------------------

function GetEntries()
	local entries = {}

	local handle = io.popen([[hyprctl binds -j | jq -c '.[]']])

	if not handle then
		return entries
	end

	for line in handle:lines() do
		local modmask = tonumber(line:match('"modmask":(%d+)')) or 0

		local key = line:match('"key":"([^"]*)"') or ""

		local description = line:match('"description":"([^"]*)"') or "No description"

		local dispatcher = line:match('"dispatcher":"([^"]*)"') or ""

		local arg = line:match('"arg":"([^"]*)"') or ""

		local mod_string = modmask_to_string(modmask)

		local text = key

		if mod_string ~= "" then
			text = mod_string .. " + " .. key
		end

		table.insert(entries, {
			Text = text,

			Subtext = description .. " -> " .. dispatcher,

			Match = text .. " " .. description .. " " .. dispatcher .. " " .. arg,

			Icon = "preferences-desktop-keyboard",
		})
	end

	handle:close()

	return entries
end
