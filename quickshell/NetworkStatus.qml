import QtQuick
import Quickshell

BarChunk {
	id: root

	text: Stats.wifiConnected ? "󰤨 " + Stats.wifiSsid : "󰤭"
	color: Stats.wifiConnected ? Colors.color5 : Colors.muted

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: (mouse) => {
			if (mouse.button === Qt.LeftButton)
				Quickshell.execDetached(["kitty", "--class", "floating_impala", "impala"])
			else
				Quickshell.execDetached(["iwctl", "station", "wlan0", "scan"])
		}
	}

}
