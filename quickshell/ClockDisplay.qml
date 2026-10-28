import QtQuick
import Quickshell

BarChunk {
	id: root

	property bool alternate: false

	text: root.alternate ? Qt.formatDateTime(clock.date, "ddd dd MMM yyyy") : Qt.formatDateTime(clock.date, "HH:mm")
	horizontalPadding: 15
	divider: false

	SystemClock {
		id: clock

		precision: SystemClock.Minutes
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: (mouse) => {
			if (mouse.button === Qt.LeftButton)
				root.alternate = !root.alternate
			else
				Quickshell.execDetached(["kitty", "--class=peaclock", "-e", "peaclock"])
		}
	}

}
