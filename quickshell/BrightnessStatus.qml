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
		acceptedButtons: Qt.NoButton
		hoverEnabled: true
		onEntered: brightnessSlider.show()
		onExited: brightnessSlider.scheduleClose()
		onWheel: (wheel) => {
			Osd.adjustBrightness(wheel.angleDelta.y > 0 ? "up" : "down", 2)
		}
	}

	BarSliderPopup {
		id: brightnessSlider

		anchorItem: root
		iconText: root.brightnessIcon(Stats.brightness)
		value: Stats.brightness
		from: 10
		to: 100
		onValueMoved: (value) => {
			Osd.setBrightness(value)
			Stats.brightness = Math.round(value)
		}
		onValueCommitted: (value) => {
			Osd.setBrightness(value)
			Stats.brightness = Math.round(value)
		}
	}

}
