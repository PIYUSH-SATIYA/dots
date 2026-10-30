import QtQuick
import Quickshell

BarChunk {
	id: root

	function brightnessIcon(value) {
		if (value >= 75)
			return "󰃠"

		if (value >= 50)
			return "󰃟"

		if (value >= 25)
			return "󰃝"

		return "󰃞"
	}

	visible: Stats.brightness > 0
	text: root.brightnessIcon(Stats.brightness)
	color: Colors.foreground

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onWheel: (wheel) => {
			Osd.adjustBrightness(wheel.angleDelta.y > 0 ? "up" : "down", 2)
		}
	}

}
