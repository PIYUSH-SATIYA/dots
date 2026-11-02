import QtQuick
import Quickshell

PopupWindow {
	id: root

	property Item anchorItem
	property string iconText: ""
	property real value: 0
	property real from: 0
	property real to: 100
	property bool muted: false
	property bool opened: false
	property real pendingValue: 0

	signal valueMoved(real value)
	signal valueCommitted(real value)

	function show() {
		closeTimer.stop()
		root.opened = true
	}

	function scheduleClose() {
		closeTimer.restart()
	}

	visible: root.opened
	anchor.item: root.anchorItem
	anchor.edges: Edges.Left
	anchor.gravity: Edges.Right
	anchor.adjustment: PopupAdjustment.Slide
	implicitWidth: 148
	implicitHeight: 24
	color: "transparent"
	grabFocus: false

	Timer {
		id: closeTimer

		interval: 220
		onTriggered: root.opened = false
	}

	Timer {
		id: moveTimer

		interval: 80
		onTriggered: root.valueMoved(root.pendingValue)
	}

	Rectangle {
		anchors.fill: parent
		radius: 6
		color: Qt.alpha(Colors.color0, 0.98)
		border.width: 1
		border.color: Colors.separator

		HoverHandler {
			onHoveredChanged: {
				if (hovered)
					closeTimer.stop()
				else
					closeTimer.restart()
			}
		}

		Row {
			anchors {
				fill: parent
				leftMargin: 7
				rightMargin: 7
			}
			spacing: 6

			Text {
				width: 14
				anchors.verticalCenter: parent.verticalCenter
				text: root.iconText
				color: root.muted ? Colors.muted : Colors.foreground
				horizontalAlignment: Text.AlignHCenter
				font.family: "CaskaydiaCove Nerd Font Propo"
				font.pixelSize: 12
				font.weight: Font.DemiBold
			}

			ControlSlider {
				id: slider

				width: parent.width - 14 - 32 - 12
				height: 14
				anchors.verticalCenter: parent.verticalCenter
				from: root.from
				to: root.to
				value: root.value
				onMoved: (value) => {
					root.pendingValue = value
					moveTimer.restart()
				}
				onReleased: (value) => {
					moveTimer.stop()
					root.valueCommitted(value)
				}
			}

			Text {
				width: 32
				anchors.verticalCenter: parent.verticalCenter
				text: Math.round(slider.displayValue) + "%"
				color: Colors.foreground
				horizontalAlignment: Text.AlignRight
				font.family: "CaskaydiaCove Nerd Font Propo"
				font.pixelSize: 9
				font.weight: Font.DemiBold
			}
		}
	}
}
