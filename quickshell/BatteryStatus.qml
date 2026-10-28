import QtQuick
import Quickshell.Services.UPower

BarChunk {
	id: root

	readonly property var device: UPower.displayDevice
	readonly property bool present: root.device !== null && root.device.isPresent
	readonly property bool charging: root.present && (root.device.state === UPowerDeviceState.Charging || root.device.state === UPowerDeviceState.PendingCharge)
	readonly property bool full: root.present && root.device.state === UPowerDeviceState.FullyCharged
	readonly property int percentage: root.present ? Math.round(root.device.percentage * 100) : 0

	function batteryIcon(value) {
		if (value >= 90)
			return "󰁹"

		if (value >= 70)
			return "󰂂"

		if (value >= 50)
			return "󰁿"

		if (value >= 30)
			return "󰁾"

		if (value >= 15)
			return "󰁼"

		return "󰁺"
	}

	visible: root.present
	text: " " + (root.charging ? "󰂄" : (root.full ? "󰁹" : root.batteryIcon(root.percentage))) + " " + root.percentage + "%"
	color: root.charging || root.full ? Colors.color5 : (root.percentage <= 15 ? Colors.color2 : (root.percentage <= 30 ? Colors.warning : Colors.foreground))
}
