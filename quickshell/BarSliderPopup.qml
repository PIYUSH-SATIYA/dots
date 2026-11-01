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
	anchor.edges: Edges.Bottom | Edges.Right
	anchor.gravity: Edges.Bottom | Edges.Right
	anchor.margins.top: 4
	anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide
	implicitWidth: 226
	implicitHeight: 58
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
		radius: 10
		color: Qt.alpha(Colors.color0, 0.97)
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
				leftMargin: 12
				rightMargin: 12
			}
			spacing: 10

			Text {
				width: 22
				anchors.verticalCenter: parent.verticalCenter
				text: root.iconText
				color: root.muted ? Colors.muted : Colors.foreground
				horizontalAlignment: Text.AlignHCenter
				font.family: "CaskaydiaCove Nerd Font Propo"
				font.pixelSize: 16
				font.weight: Font.DemiBold
			}

			ControlSlider {
				id: slider

				width: parent.width - 22 - 44 - 20
				height: 20
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
				width: 44
				anchors.verticalCenter: parent.verticalCenter
				text: Math.round(slider.displayValue) + "%"
				color: Colors.foreground
				horizontalAlignment: Text.AlignRight
				font.family: "CaskaydiaCove Nerd Font Propo"
				font.pixelSize: 11
				font.weight: Font.DemiBold
			}
		}
	}
}
