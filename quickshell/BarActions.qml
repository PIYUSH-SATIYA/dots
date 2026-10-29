import QtQuick
import Quickshell

Row {
	BarChunk {
		text: "󰂚"
		color: NotificationHub.dnd ? Colors.muted : Colors.accent
		fontSize: 14
		divider: false

		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: NotificationHub.toggleCenter()
		}

	}

	BarChunk {
		text: "QS"
		color: Colors.accent
		fontSize: 14
		divider: false
		horizontalPadding: 10

		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: Quickshell.execDetached(["walker", "-t", "pywal"])
		}

	}

}
