pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	readonly property var palette: wal.colors ? wal.colors : ({})
	readonly property var specialColors: wal.special ? wal.special : ({})

	readonly property color background: root.specialColors.background ? root.specialColors.background : "#111c18"
	readonly property color foreground: root.specialColors.foreground ? root.specialColors.foreground : "#c1c497"
	readonly property color cursor: root.specialColors.cursor ? root.specialColors.cursor : "#d7c995"

	readonly property color color0: root.palette.color0 ? root.palette.color0 : "#23372b"
	readonly property color color1: root.palette.color1 ? root.palette.color1 : "#ff5345"
	readonly property color color2: root.palette.color2 ? root.palette.color2 : "#549e6a"
	readonly property color color3: root.palette.color3 ? root.palette.color3 : "#459451"
	readonly property color color4: root.palette.color4 ? root.palette.color4 : "#509475"
	readonly property color color5: root.palette.color5 ? root.palette.color5 : "#d2689c"
	readonly property color color6: root.palette.color6 ? root.palette.color6 : "#2dd5b7"
	readonly property color color7: root.palette.color7 ? root.palette.color7 : "#f6f5dd"
	readonly property color color8: root.palette.color8 ? root.palette.color8 : "#53685b"
	readonly property color color9: root.palette.color9 ? root.palette.color9 : "#db9f9c"
	readonly property color color10: root.palette.color10 ? root.palette.color10 : "#63b07a"
	readonly property color color11: root.palette.color11 ? root.palette.color11 : "#e5c736"
	readonly property color color12: root.palette.color12 ? root.palette.color12 : "#acd4cf"
	readonly property color color13: root.palette.color13 ? root.palette.color13 : "#75bbb3"
	readonly property color color14: root.palette.color14 ? root.palette.color14 : "#8cd3cb"
	readonly property color color15: root.palette.color15 ? root.palette.color15 : "#9eebb3"

	readonly property color accent: color6
	readonly property color muted: color8
	readonly property color warning: color3
	readonly property color error: color1
	readonly property color success: color2
	readonly property color blue: color4
	readonly property color workspace: color7
	readonly property color separator: Qt.alpha(muted, 0.35)

	FileView {
		id: colorsFile
		path: Quickshell.env("HOME") + "/.cache/wal/colors.json"
		watchChanges: true
		printErrors: false
		onFileChanged: reload()

		JsonAdapter {
			id: wal
			property string alpha: "100"
			property string wallpaper: ""
			property var colors: ({})
			property var special: ({})
		}
	}
}
