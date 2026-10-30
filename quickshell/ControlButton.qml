import QtQuick

Item {
	id: root

	property string icon: ""
	property bool active: false
	property color activeColor: Colors.accent

	signal clicked()

	implicitHeight: 44

	Rectangle {
		anchors.fill: parent
		radius: 8
		color: root.active
			? Qt.alpha(root.activeColor, 0.22)
			: (mouse.containsMouse ? Qt.alpha(Colors.foreground, 0.12) : Qt.alpha(Colors.foreground, 0.06))
		border.width: 1
		border.color: root.active ? Qt.alpha(root.activeColor, 0.5) : Colors.separator

		Text {
			anchors.centerIn: parent
			text: root.icon
			color: root.active ? root.activeColor : Colors.foreground
			font.family: "CaskaydiaCove Nerd Font Propo"
			font.pixelSize: 19
			font.weight: Font.DemiBold
		}
	}

	MouseArea {
		id: mouse

		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true
		onClicked: root.clicked()
	}
}
