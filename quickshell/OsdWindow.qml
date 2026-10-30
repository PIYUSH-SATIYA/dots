import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
	PanelWindow {
		visible: Osd.visible
		anchors.bottom: true
		margins.bottom: 160
		implicitWidth: 276
		implicitHeight: 64
		exclusiveZone: 0
		focusable: false
		color: "transparent"
		WlrLayershell.namespace: "quickshell-osd"
		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

		Rectangle {
			anchors.fill: parent
			radius: height / 2
			color: Qt.alpha(Colors.color0, 0.92)

			Row {
				anchors {
					left: parent.left
					right: parent.right
					verticalCenter: parent.verticalCenter
					leftMargin: 18
					rightMargin: 18
				}
				spacing: 12

				Text {
					width: 24
					height: 24
					text: Osd.icon
					color: Colors.foreground
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					font.family: "CaskaydiaCove Nerd Font Propo"
					font.pixelSize: 20
					font.weight: Font.DemiBold
				}

				Item {
					width: parent.width - 24 - 46 - 24
					height: 24

					Rectangle {
						anchors {
							left: parent.left
							right: parent.right
							verticalCenter: parent.verticalCenter
						}
						height: 6
						radius: 3
						color: Qt.alpha(Colors.foreground, 0.22)
					}

					Rectangle {
						anchors {
							left: parent.left
							verticalCenter: parent.verticalCenter
						}
						width: Math.max(0, Math.min(parent.width, parent.width * Osd.value))
						height: 6
						radius: 3
						color: Colors.foreground
					}
				}

				Text {
					width: 46
					height: 24
					text: Osd.text
					color: Colors.foreground
					horizontalAlignment: Text.AlignRight
					verticalAlignment: Text.AlignVCenter
					font.family: "CaskaydiaCove Nerd Font Propo"
					font.pixelSize: 13
					font.weight: Font.DemiBold
				}
			}
		}
	}

	IpcHandler {
		target: "osd"

		function volumeUp(step: int) {
			Osd.adjustVolume(Math.abs(Number(step)) || 5)
		}

		function volumeDown(step: int) {
			Osd.adjustVolume(-(Math.abs(Number(step)) || 5))
		}

		function toggleMute() {
			Osd.toggleMute()
		}

		function setVolume(step: int) {
			Osd.setVolume(step)
		}

		function brightnessUp(step: int) {
			Osd.adjustBrightness("up", Math.abs(Number(step)) || 5)
		}

		function brightnessDown(step: int) {
			Osd.adjustBrightness("down", Math.abs(Number(step)) || 5)
		}

		function setBrightness(step: int) {
			Osd.setBrightness(step)
		}
	}
}
