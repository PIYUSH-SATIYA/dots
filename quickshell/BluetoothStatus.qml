import QtQuick
import Quickshell
import Quickshell.Bluetooth

BarChunk {
	id: root

	readonly property var adapter: Bluetooth.defaultAdapter
	readonly property var connectedDevice: {
		for (const device of Bluetooth.devices.values) {
			if (device.connected)
				return device

		}
		return null
	}

	text: !root.adapter || !root.adapter.enabled ? "󰂲" : (root.connectedDevice ? "󰂱 " + (root.connectedDevice.name || root.connectedDevice.deviceName) : "󰂯")
	color: root.adapter && root.adapter.enabled ? Colors.color4 : Colors.muted

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: Quickshell.execDetached(["kitty", "--class", "floating_bluetui", "bluetui"])
	}

}
