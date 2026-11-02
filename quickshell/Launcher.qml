import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

Scope {
	id: root

	readonly property string dataScript: Quickshell.env("HOME") + "/.config/quickshell/scripts/launcher-data.py"
	readonly property var prefixModes: ({
		"=": "calc",
		"/": "files",
		".": "symbols",
		"@": "web",
		">": "runner",
		":": "clipboard",
		"?": "keybinds",
		"`": "themes",
		"!": "wallpapers",
		"$": "windows",
	})
	readonly property var modeLabels: ({
		apps: "Applications",
		files: "Files",
		clipboard: "Clipboard",
		themes: "Themes",
		wallpapers: "Wallpapers",
		keybinds: "Keybinds",
		symbols: "Symbols",
		calc: "Calculator",
		web: "Web",
		runner: "Runner",
		windows: "Windows",
		help: "Help",
	})
	readonly property string effectiveMode: {
		if (LauncherHub.mode === "apps")
			return root.prefixModes[LauncherHub.query.charAt(0)] || "apps"

		return root.modeLabels[LauncherHub.mode] ? LauncherHub.mode : "apps"
	}
	readonly property string effectiveQuery: {
		if (LauncherHub.mode === "apps" && root.prefixModes[LauncherHub.query.charAt(0)])
			return LauncherHub.query.slice(1)

		return LauncherHub.query
	}
	readonly property bool remoteMode: root.effectiveMode === "files" || root.effectiveMode === "calc"
	readonly property bool specialMode: root.effectiveMode === "web" || root.effectiveMode === "runner" || root.effectiveMode === "help"
	readonly property string modeLabel: root.modeLabels[root.effectiveMode] || "Applications"
	readonly property string placeholderText: {
		if (root.effectiveMode === "files")
			return "Search files..."

		if (root.effectiveMode === "clipboard")
			return "Search clipboard..."

		if (root.effectiveMode === "calc")
			return "Enter an expression..."

		if (root.effectiveMode === "web")
			return "Search the web or enter a URL..."

		if (root.effectiveMode === "runner")
			return "Enter a command..."

		if (root.effectiveMode === "symbols")
			return "Search symbols..."

		return "Search applications..."
	}
	readonly property var helpItems: [
		{
			kind: "help",
			name: "Applications",
			subtitle: "Search installed desktop applications",
			icon: "applications-system",
			action: "mode",
			arg: "apps",
			search: "applications apps",
		},
		{
			kind: "help",
			name: "Files",
			subtitle: "Search files under your home directory with fd",
			icon: "system-file-manager",
			action: "mode",
			arg: "files",
			search: "files fd",
		},
		{
			kind: "help",
			name: "Clipboard",
			subtitle: "Browse and copy clipboard history",
			icon: "edit-paste",
			action: "mode",
			arg: "clipboard",
			search: "clipboard copy paste",
		},
		{
			kind: "help",
			name: "Themes",
			subtitle: "Apply a static theme",
			icon: "preferences-desktop-theme",
			action: "mode",
			arg: "themes",
			search: "themes colors",
		},
		{
			kind: "help",
			name: "Wallpapers",
			subtitle: "Choose a wallpaper",
			icon: "image-x-generic",
			action: "mode",
			arg: "wallpapers",
			search: "wallpapers background",
		},
		{
			kind: "help",
			name: "Keybinds",
			subtitle: "Search Hyprland keybindings",
			icon: "preferences-desktop-keyboard",
			action: "mode",
			arg: "keybinds",
			search: "keybinds shortcuts",
		},
		{
			kind: "help",
			name: "Symbols",
			subtitle: "Search unicode symbols and emoji",
			icon: "accessories-character-map",
			action: "mode",
			arg: "symbols",
			search: "symbols emoji unicode",
		},
		{
			kind: "help",
			name: "Calculator",
			subtitle: "Evaluate an expression with qalc",
			icon: "accessories-calculator",
			action: "mode",
			arg: "calc",
			search: "calculator calc math",
		},
		{
			kind: "help",
			name: "Web",
			subtitle: "Search the web or open a URL",
			icon: "applications-internet",
			action: "mode",
			arg: "web",
			search: "web search url",
		},
		{
			kind: "help",
			name: "Runner",
			subtitle: "Run a shell command",
			icon: "utilities-terminal",
			action: "mode",
			arg: "runner",
			search: "runner command shell",
		},
		{
			kind: "help",
			name: "Windows",
			subtitle: "Focus an open Hyprland window",
			icon: "preferences-system-windows",
			action: "mode",
			arg: "windows",
			search: "windows clients focus",
		},
	]
	readonly property var results: root.computeResults()
	readonly property var selectedItem: root.results[root.selected] || null

	property var catalog: ({})
	property var remoteItems: []
	property int selected: 0
	property bool catalogLoaded: false
	property string message: ""
	property int querySerial: 0
	property bool queryBusy: false
	property bool queryPending: false
	property bool clipboardRefreshing: false
	property string clipboardPreview: ""
	property int previewSerial: 0
	property bool previewPending: false

	function normalize(value) {
		return String(value || "").toLowerCase()
	}

	function scoreItem(item, query) {
		const haystack = root.normalize(item.search || item.name || "")

		if (haystack === query)
			return 0

		const index = haystack.indexOf(query)

		if (index < 0)
			return -1

		if (index === 0)
			return 1

		const previous = haystack.charAt(index - 1)

		if (previous === " " || previous === "-" || previous === "/" || previous === ".")
			return 2

		return 3
	}

	function scoreItems(items, query) {
		if (!Array.isArray(items))
			return []

		if (!query)
			return items.slice(0, 100)

		const scored = []

		for (let index = 0; index < items.length; index++) {
			const item = items[index]
			const rank = root.scoreItem(item, query)

			if (rank < 0)
				continue

			scored.push({
				item: item,
				rank: rank,
				label: root.normalize(item.name),
			})
		}

		scored.sort((left, right) => {
			if (left.rank !== right.rank)
				return left.rank - right.rank

			if (left.label < right.label)
				return -1

			if (left.label > right.label)
				return 1

			return 0
		})

		return scored.slice(0, 100).map(entry => entry.item)
	}

	function webUri(value) {
		if (/^https?:\/\//i.test(value))
			return value

		if (/^[\w.-]+\.[a-z]{2,}(\/.*)?$/i.test(value))
			return "https://" + value

		return "https://duckduckgo.com/?q=" + encodeURIComponent(value)
	}

	function computeResults() {
		const query = root.normalize(root.effectiveQuery.trim())

		if (root.remoteMode)
			return root.remoteItems

		if (root.effectiveMode === "help")
			return root.helpItems

		if (root.effectiveMode === "web") {
			if (!query)
				return []

			const value = root.effectiveQuery.trim()
			const target = root.webUri(value)

			return [{
				kind: "web",
				name: value,
				subtitle: target,
				icon: "applications-internet",
				action: "web",
				arg: target,
				search: query,
			}]
		}

		if (root.effectiveMode === "runner") {
			if (!query)
				return []

			const value = root.effectiveQuery.trim()

			return [{
				kind: "runner",
				name: value,
				subtitle: "Run command",
				icon: "utilities-terminal",
				action: "runner",
				arg: value,
				search: query,
			}]
		}

		return root.scoreItems(root.catalog[root.effectiveMode] || [], query)
	}

	function emptyText() {
		if (root.message)
			return root.message

		if (!root.catalogLoaded && !root.remoteMode && !root.specialMode)
			return "Loading..."

		if (root.effectiveMode === "web")
			return "Type a search or URL"

		if (root.effectiveMode === "runner")
			return "Type a command to run"

		if (root.remoteMode && !root.effectiveQuery.trim())
			return "Type to search " + root.modeLabel.toLowerCase()

		return "No results"
	}

	function panelWidth(mode) {
		if (mode === "clipboard")
			return 1040

		if (mode === "files" || mode === "keybinds" || mode === "wallpapers")
			return 760

		if (mode === "symbols")
			return 500

		return 660
	}

	function panelHeight(mode) {
		if (mode === "clipboard")
			return 680

		if (mode === "keybinds")
			return 600

		if (mode === "files" || mode === "wallpapers" || mode === "symbols")
			return 560

		return 500
	}

	function focusSearch() {
		search.forceActiveFocus()
		search.cursorPosition = search.text.length
	}

	function close() {
		LauncherHub.close()
	}

	function moveSelection(delta) {
		if (root.results.length === 0)
			return

		let next = root.selected + delta

		if (next < 0)
			next = root.results.length - 1

		if (next >= root.results.length)
			next = 0

		root.selected = next
	}

	function activateSelected() {
		root.activate(root.results[root.selected])
	}

	function copyText(value) {
		Quickshell.execDetached([
			"bash",
			"-c",
			"printf %s \"$1\" | wl-copy",
			"launcher-copy",
			String(value),
		])
	}

	function activate(item) {
		if (!item)
			return

		if (item.action === "mode") {
			LauncherHub.show(item.arg)
			Qt.callLater(root.focusSearch)
			return
		}

		if (item.action === "app") {
			if (item.desktop)
				Quickshell.execDetached(["gio", "launch", item.desktop])
			else if (item.exec)
				Quickshell.execDetached(["bash", "-lc", item.exec])
		} else if (item.action === "clipboard") {
			const identifier = String(item.arg || "").replace(/[^0-9]/g, "")

			if (identifier)
				Quickshell.execDetached([
					"bash",
					"-c",
					"cliphist decode \"$1\" | wl-copy",
					"launcher-clipboard",
					identifier,
				])
		} else if (item.action === "theme") {
			Quickshell.execDetached([
				"bash",
				Quickshell.env("HOME") + "/.config/theme-system/set-theme.sh",
				item.arg,
			])
		} else if (item.action === "dynamic") {
			Quickshell.execDetached([
				"bash",
				Quickshell.env("HOME") + "/.config/theme-system/set-dynamic.sh",
			])
		} else if (item.action === "wallpaper") {
			Quickshell.execDetached([
				"bash",
				Quickshell.env("HOME") + "/.config/theme-system/set-wallpaper.sh",
				item.arg,
			])
		} else if (item.action === "file") {
			Quickshell.execDetached(["xdg-open", item.arg])
		} else if (item.action === "copy") {
			root.copyText(item.arg)
		} else if (item.action === "web") {
			Quickshell.execDetached(["xdg-open", item.arg])
		} else if (item.action === "runner") {
			Quickshell.execDetached(["bash", "-lc", item.arg])
		} else if (item.action === "window") {
			Quickshell.execDetached(["hyprctl", "dispatch", "focuswindow", "address:" + item.arg])
		}

		root.close()
	}

	function refreshCatalog() {
		if (catalogProcess.running)
			return

		catalogProcess.running = true
	}

	function refreshClipboard() {
		if (root.clipboardRefreshing)
			return

		root.clipboardRefreshing = true
		clipboardProcess.running = true
	}

	function previewIdentifier(item) {
		return String(item && item.arg || "").replace(/[^0-9]/g, "")
	}

	function refreshClipboardPreview() {
		const item = root.selectedItem

		if (root.effectiveMode !== "clipboard" || !item || item.binary) {
			root.previewSerial += 1
			root.previewPending = false
			root.clipboardPreview = ""
			return
		}

		const identifier = root.previewIdentifier(item)

		if (!identifier) {
			root.clipboardPreview = ""
			return
		}

		root.previewSerial += 1
		root.clipboardPreview = ""

		if (clipboardPreviewProcess.running) {
			root.previewPending = true
			return
		}

		root.startClipboardPreview(identifier, root.previewSerial)
	}

	function startClipboardPreview(identifier, serial) {
		root.previewPending = false
		clipboardPreviewProcess.requestId = identifier
		clipboardPreviewProcess.requestSerial = serial
		clipboardPreviewProcess.running = true
	}

	function scheduleRemote() {
		if (!LauncherHub.open)
			return

		if (root.effectiveQuery.trim())
			searchTimer.restart()
		else
			root.clearRemote()
	}

	function startQuery() {
		if (!root.remoteMode || !root.effectiveQuery.trim()) {
			root.queryPending = false
			return
		}

		root.queryBusy = true
		root.queryPending = false
		queryProcess.serial = root.querySerial
		queryProcess.requestMode = root.effectiveMode
		queryProcess.requestQuery = root.effectiveQuery.trim()
		queryProcess.running = true
	}

	function requestRemote() {
		root.querySerial += 1

		if (root.queryBusy || queryProcess.running) {
			root.queryPending = true
			return
		}

		root.startQuery()
	}

	function clearRemote() {
		root.querySerial += 1
		root.queryPending = false
		root.remoteItems = []
		root.message = ""
	}

	Component.onCompleted: {
		if (LauncherHub.open) {
			root.refreshCatalog()
			Qt.callLater(root.focusSearch)
		}
	}

	Connections {
		target: LauncherHub

		function onOpenChanged() {
			if (!LauncherHub.open) {
				root.clearRemote()
				search.text = ""
				return
			}

			root.selected = 0
			root.remoteItems = []
			root.message = ""
			search.text = LauncherHub.query
			root.refreshCatalog()
			root.scheduleRemote()
			root.refreshClipboardPreview()
			Qt.callLater(root.focusSearch)
		}

		function onModeChanged() {
			if (!LauncherHub.open)
				return

			root.selected = 0
			root.remoteItems = []
			search.text = LauncherHub.query
			root.scheduleRemote()
			root.refreshClipboardPreview()
			Qt.callLater(root.focusSearch)
		}

		function onQueryChanged() {
			if (search.text !== LauncherHub.query)
				search.text = LauncherHub.query

			root.selected = 0
		}
	}

	onEffectiveModeChanged: {
		root.selected = 0
		root.remoteItems = []
		root.scheduleRemote()
		root.refreshClipboardPreview()
	}

	onEffectiveQueryChanged: {
		root.selected = 0
		root.scheduleRemote()
	}

	Timer {
		id: searchTimer

		interval: 140
		onTriggered: {
			if (root.remoteMode && root.effectiveQuery.trim())
				root.requestRemote()
		}
	}

	Timer {
		id: clipboardRefreshTimer

		interval: 1000
		repeat: true
		running: LauncherHub.open && root.effectiveMode === "clipboard"
		onTriggered: root.refreshClipboard()
	}

	Process {
		id: clipboardProcess

		command: ["python3", root.dataScript, "clipboard"]

		stdout: StdioCollector {
			onStreamFinished: {
				const text = this.text.trim()

				if (!text)
					return

				try {
					const data = JSON.parse(text)

					if (Array.isArray(data)) {
						const next = Object.assign({}, root.catalog)
						next.clipboard = data
						root.catalog = next
					}
				} catch (error) {
					root.message = "Clipboard refresh failed"
				}
			}
		}

		onExited: root.clipboardRefreshing = false
	}

	Process {
		id: clipboardPreviewProcess

		property string requestId: ""
		property int requestSerial: 0

		command: ["cliphist", "decode", clipboardPreviewProcess.requestId]

		stdout: StdioCollector {
			onStreamFinished: {
				if (clipboardPreviewProcess.requestSerial !== root.previewSerial)
					return

				root.clipboardPreview = this.text
			}
		}

		onExited: {
			if (root.previewPending)
				root.refreshClipboardPreview()
		}
	}

	Process {
		id: catalogProcess

		command: ["python3", root.dataScript, "all", ""]

		stdout: StdioCollector {
			onStreamFinished: {
				const text = this.text.trim()

				if (!text)
					return

				try {
					const data = JSON.parse(text)

					if (data && typeof data === "object" && !Array.isArray(data)) {
						root.catalog = data
						root.catalogLoaded = true
						root.message = ""
					}
				} catch (error) {
					root.message = "Launcher data failed to load"
				}
			}
		}

		onExited: (exitCode) => {
			if (exitCode !== 0)
				root.message = "Launcher data unavailable"
		}
	}

	Process {
		id: queryProcess

		property int serial: 0
		property string requestMode: "files"
		property string requestQuery: ""

		command: ["python3", root.dataScript, queryProcess.requestMode, queryProcess.requestQuery]

		stdout: StdioCollector {
			onStreamFinished: {
				if (queryProcess.serial !== root.querySerial)
					return

				const text = this.text.trim()

				if (!text) {
					root.remoteItems = []
					return
				}

				try {
					const data = JSON.parse(text)
					root.remoteItems = Array.isArray(data) ? data : []
					root.message = ""
				} catch (error) {
					root.remoteItems = []
					root.message = "Launcher query failed"
				}
			}
		}

		onExited: (exitCode) => {
			root.queryBusy = false

			if (root.queryPending || queryProcess.serial !== root.querySerial) {
				root.queryPending = false

				if (root.remoteMode && root.effectiveQuery.trim())
					root.startQuery()
			}

			if (exitCode !== 0 && queryProcess.serial === root.querySerial)
				root.message = "Launcher query failed"
		}
	}

	PanelWindow {
		id: window

		visible: LauncherHub.open
		anchors {
			top: true
			bottom: true
			left: true
			right: true
		}
		exclusiveZone: 0
		focusable: true
		aboveWindows: true
		color: "transparent"
		WlrLayershell.namespace: "quickshell-launcher"
		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.keyboardFocus: LauncherHub.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

		onVisibleChanged: {
			if (visible)
				Qt.callLater(root.focusSearch)
			else
				search.focus = false
		}

		Shortcut {
			sequence: "Escape"
			context: Qt.WindowShortcut
			onActivated: root.close()
		}

		Rectangle {
			anchors.fill: parent
			color: Qt.alpha("#000000", 0.48)

			MouseArea {
				anchors.fill: parent
				onClicked: root.close()
			}
		}

		Rectangle {
			id: panel

			anchors.centerIn: parent
			width: Math.min(root.panelWidth(root.effectiveMode), parent.width - 80)
			height: Math.min(root.panelHeight(root.effectiveMode), parent.height - 100)
			radius: 16
			color: Qt.alpha(Colors.color0, 0.97)
			border.width: 1
			border.color: Colors.separator

			MouseArea {
				anchors.fill: parent
			}

			Column {
				anchors {
					fill: parent
					margins: 14
				}
				spacing: 10

				Rectangle {
					width: parent.width
					height: 42
					radius: 8
					color: Qt.alpha(Colors.foreground, 0.06)
					border.width: 1
					border.color: Colors.separator

					Text {
						anchors {
							left: parent.left
							verticalCenter: parent.verticalCenter
							leftMargin: 12
						}
						text: root.placeholderText
						visible: search.text.length === 0
						color: Colors.muted
						font.family: "CaskaydiaCove Nerd Font Propo"
						font.pixelSize: 14
						font.weight: Font.DemiBold
					}

					TextInput {
						id: search

						anchors {
							left: parent.left
							right: parent.right
							verticalCenter: parent.verticalCenter
							leftMargin: 12
							rightMargin: 12
						}
						height: 26
						text: ""
						color: Colors.foreground
						selectionColor: Qt.alpha(Colors.accent, 0.4)
						selectedTextColor: Colors.foreground
						font.family: "CaskaydiaCove Nerd Font Propo"
						font.pixelSize: 14
						font.weight: Font.DemiBold
						selectByMouse: true
						clip: true
						onTextEdited: {
							LauncherHub.query = text
							root.selected = 0
						}
						Keys.onPressed: (event) => {
							const gridStep = root.effectiveMode === "symbols" ? 4 : 1

							if (event.key === Qt.Key_Escape) {
								root.close()
								event.accepted = true
							} else if (root.effectiveMode === "symbols" && event.key === Qt.Key_Left) {
								root.moveSelection(-1)
								event.accepted = true
							} else if (root.effectiveMode === "symbols" && event.key === Qt.Key_Right) {
								root.moveSelection(1)
								event.accepted = true
							} else if (event.key === Qt.Key_Up) {
								root.moveSelection(-gridStep)
								event.accepted = true
							} else if (event.key === Qt.Key_Down) {
								root.moveSelection(gridStep)
								event.accepted = true
							} else if (event.key === Qt.Key_PageUp) {
								root.moveSelection(-6)
								event.accepted = true
							} else if (event.key === Qt.Key_PageDown) {
								root.moveSelection(6)
								event.accepted = true
							} else if (event.key === Qt.Key_Tab) {
								root.moveSelection(1)
								event.accepted = true
							} else if (event.key === Qt.Key_Backtab) {
								root.moveSelection(-1)
								event.accepted = true
							} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
								root.activateSelected()
								event.accepted = true
							} else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_N) {
								root.moveSelection(1)
								event.accepted = true
							} else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_P) {
								root.moveSelection(-1)
								event.accepted = true
							}
						}
					}
				}

				Row {
					id: contentRow

					readonly property real previewWidth: root.effectiveMode === "clipboard" ? Math.round(width * 0.58) : 0

					width: parent.width
					height: Math.max(0, parent.height - 52)
					spacing: 10

					Item {
						id: listArea

						width: root.effectiveMode === "clipboard"
							? Math.max(0, contentRow.width - contentRow.previewWidth - contentRow.spacing)
							: contentRow.width
						height: parent.height


						ListView {
							id: launcherList

							visible: root.effectiveMode !== "symbols"
							anchors.fill: parent
							model: root.results
							spacing: 2
							clip: true
							boundsBehavior: Flickable.StopAtBounds

							onCountChanged: {
								if (root.selected >= count)
									root.selected = Math.max(0, count - 1)
							}

							delegate: Rectangle {
								id: itemRow

								required property var modelData
								required property int index

								width: launcherList.width
								height: 50
								radius: 8
								color: index === root.selected
									? Qt.alpha(Colors.accent, 0.16)
									: (rowMouse.containsMouse ? Qt.alpha(Colors.foreground, 0.07) : "transparent")

								Row {
									anchors {
										fill: parent
										leftMargin: 10
										rightMargin: 10
									}
									spacing: 10

									Item {
										width: 28
										height: 28
										anchors.verticalCenter: parent.verticalCenter

										IconImage {
											id: itemIcon

											anchors.fill: parent
											source: Quickshell.iconPath(itemRow.modelData.icon || "", true)
											visible: source !== ""
										}

										Text {
											anchors.centerIn: parent
											visible: itemIcon.source === ""
											text: itemRow.modelData.glyph || "󰈔"
											color: Colors.foreground
											font.family: "CaskaydiaCove Nerd Font Propo"
											font.pixelSize: 20
											font.weight: Font.DemiBold
										}
									}

									Column {
										width: parent.width - 28 - 20
										anchors.verticalCenter: parent.verticalCenter
										spacing: 2

										Text {
											width: parent.width
											text: itemRow.modelData.name || ""
											color: Colors.foreground
											elide: Text.ElideRight
											textFormat: Text.PlainText
											font.family: "CaskaydiaCove Nerd Font Propo"
											font.pixelSize: 13
											font.weight: Font.DemiBold
										}

										Text {
											width: parent.width
											text: itemRow.modelData.subtitle || ""
											color: Colors.muted
											elide: Text.ElideRight
											textFormat: Text.PlainText
											font.family: "CaskaydiaCove Nerd Font Propo"
											font.pixelSize: 11
											font.weight: Font.DemiBold
										}
									}
								}

								MouseArea {
									id: rowMouse

									anchors.fill: parent
									hoverEnabled: true
									cursorShape: Qt.PointingHandCursor
									onClicked: root.activate(itemRow.modelData)
								}
							}
						}

						GridView {
							id: symbolGrid

							visible: root.effectiveMode === "symbols"
							anchors.fill: parent
							model: root.results
							cellWidth: width / 4
							cellHeight: 64
							clip: true
							boundsBehavior: Flickable.StopAtBounds

							onCountChanged: {
								if (root.selected >= count)
									root.selected = Math.max(0, count - 1)
							}

							delegate: Rectangle {
								id: symbolCell

								required property var modelData
								required property int index

								width: symbolGrid.cellWidth
								height: symbolGrid.cellHeight
								radius: 8
								color: index === root.selected
									? Qt.alpha(Colors.accent, 0.16)
									: (symbolMouse.containsMouse ? Qt.alpha(Colors.foreground, 0.07) : "transparent")

								Text {
									anchors.centerIn: parent
									text: symbolCell.modelData.glyph || ""
									font.pixelSize: 28
								}

								MouseArea {
									id: symbolMouse

									anchors.fill: parent
									hoverEnabled: true
									cursorShape: Qt.PointingHandCursor
									onClicked: root.activate(symbolCell.modelData)
								}
							}
						}

						Text {
							anchors.centerIn: parent
							width: parent.width - 40
							visible: root.results.length === 0
							text: root.emptyText()
							color: Colors.muted
							horizontalAlignment: Text.AlignHCenter
							wrapMode: Text.Wrap
							textFormat: Text.PlainText
							font.family: "CaskaydiaCove Nerd Font Propo"
							font.pixelSize: 13
							font.weight: Font.DemiBold
						}

					}

					Rectangle {
						visible: root.effectiveMode === "clipboard"
						width: contentRow.previewWidth
						height: parent.height
						radius: 10
						color: Qt.alpha(Colors.foreground, 0.045)
						border.width: 1
						border.color: Colors.separator

						Flickable {
							anchors {
								fill: parent
								margins: 12
							}
							contentWidth: width
							contentHeight: previewText.implicitHeight
							clip: true
							boundsBehavior: Flickable.StopAtBounds

							Text {
								id: previewText

								width: parent.width
								text: root.selectedItem
									? (root.selectedItem.binary
										? "[binary clipboard entry]"
										: (root.clipboardPreview || root.selectedItem.preview || root.selectedItem.name || ""))
									: ""
								color: Colors.foreground
								wrapMode: Text.Wrap
								textFormat: Text.PlainText
								font.family: "CaskaydiaCove Nerd Font Propo"
								font.pixelSize: 12
								font.weight: Font.DemiBold
							}
						}
					}
				}

			}
		}
	}

	onSelectedItemChanged: root.refreshClipboardPreview()

	onSelectedChanged: {
		if (root.selected < 0 || root.selected >= root.results.length)
			return

		if (root.effectiveMode === "symbols")
			symbolGrid.positionViewAtIndex(root.selected, GridView.Contain)
		else
			launcherList.positionViewAtIndex(root.selected, ListView.Contain)
	}

	IpcHandler {
		target: "launcher"

		function toggle() {
			LauncherHub.toggle()
		}

		function open(mode: string) {
			LauncherHub.show(mode)
		}

		function close() {
			LauncherHub.close()
		}

		function setQuery(query: string) {
			LauncherHub.setQuery(query)
		}
	}
}
