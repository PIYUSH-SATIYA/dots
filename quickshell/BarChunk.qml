import QtQuick

Item {
	id: root

	property alias text: label.text
	property color color: Colors.foreground
	property color dividerColor: Colors.separator
	property int fontSize: 13
	property int horizontalPadding: 10
	property bool divider: true

	implicitWidth: label.implicitWidth + root.horizontalPadding * 2
	implicitHeight: 28

	Text {
		id: label

		anchors.centerIn: parent
		color: root.color
		font.family: "CaskaydiaCove Nerd Font Propo"
		font.pixelSize: root.fontSize
		font.weight: Font.DemiBold
	}

	Rectangle {
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		width: 1
		height: 14
		color: root.dividerColor
		visible: root.divider
	}

}
