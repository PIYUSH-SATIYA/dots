import QtQuick
import Quickshell

Row {
	BarChunk {
		text: "󰂚"
		color: Colors.accent
		fontSize: 14
		divider: false

		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: Quickshell.execDetached(["swaync-client", "-t"])
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
