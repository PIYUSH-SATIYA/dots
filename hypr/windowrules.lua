---@module 'hl'

-- suppress maximize events
hl.window_rule({
	name = "suppress_maximize",
	match = {
		class = ".*",
	},
	suppress_event = "maximize",
})

-- XWayland drag fix
hl.window_rule({
	name = "xwayland_drag_fix",
	match = {
		class = "^$",
		title = "^$",
		xwayland = 1,
		float = 1,
	},
	no_focus = true,
})

-- floating_impala
hl.window_rule({
	name = "floating_impala",
	match = {
		class = "^(floating_impala)$",
	},
	float = true,
	size = { 1000, 600 },
	center = true,
})

-- floating_bluetui
hl.window_rule({
	name = "floating_bluetui",
	match = {
		class = "^(floating_bluetui)$",
	},
	float = true,
	size = { 1000, 600 },
	center = true,
})

-- floating_btop
hl.window_rule({
	name = "floating_btop",
	match = {
		class = "^(floating_btop)$",
	},
	float = true,
	size = { 1200, 800 },
	center = true,
})

-- -- zathura transparency
-- hl.window_rule({
-- 	name = "zathura_opacity",
-- 	match = {
-- 		class = "^(org\\.pwmt\\.zathura)$",
-- 	},
-- 	opacity = "0.85 0.65",
-- })

-- gnome-calculator
hl.window_rule({
	name = "Calculator",
	match = {
		class = "^(org.gnome.Calculator)$",
	},
	float = true,
	size = { 400, 500 },
	center = true,
	opacity = "0.9 0.65",
})

hl.window_rule({
	name = "notes",

	match = {
		title = "^(nvim notes.md)$",
	},

	float = true,
	pin = true,

	size = { 700, 500 },
	move = { "70%", "5%" },

	opacity = 0.85,

	border_size = 0,
	no_focus = true,
})
