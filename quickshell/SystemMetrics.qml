import QtQuick
import Quickshell

Row {
	id: root

	property bool corePopupOpen: false

	Timer {
		id: coreCloseTimer

		interval: 220
		onTriggered: root.corePopupOpen = false
	}

	function temperatureIcon(value) {
		if (value >= 80)
			return ""

		if (value >= 65)
			return ""

		if (value >= 50)
			return ""

		if (value >= 35)
			return ""

		return ""
	}

	BarChunk {
		id: coresChunk

		text: Stats.cores
		fontSize: 12
		color: Colors.foreground

		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.NoButton
			hoverEnabled: true
			onEntered: {
				coreCloseTimer.stop()
				root.corePopupOpen = true
			}
			onExited: coreCloseTimer.restart()
		}
	}

	PopupWindow {
		id: corePopup

		visible: root.corePopupOpen
		anchor.item: coresChunk
		anchor.edges: Edges.Bottom | Edges.Left
		anchor.gravity: Edges.Bottom | Edges.Right
		anchor.margins.top: 4
		anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide
		implicitWidth: 230
		implicitHeight: coreColumn.implicitHeight + 24
		color: "transparent"
		grabFocus: false

		Rectangle {
			anchors.fill: parent
			radius: 10
			color: Qt.alpha(Colors.color0, 0.97)
			border.width: 1
			border.color: Colors.separator

			HoverHandler {
				onHoveredChanged: {
					if (hovered)
						coreCloseTimer.stop()
					else
						coreCloseTimer.restart()
				}
			}

			Column {
				id: coreColumn

				anchors {
					left: parent.left
					right: parent.right
					top: parent.top
					margins: 12
				}
				spacing: 5

				Text {
					text: "CPU cores"
					color: Colors.accent
					font.family: "CaskaydiaCove Nerd Font Propo"
					font.pixelSize: 12
					font.weight: Font.DemiBold
				}

				Repeater {
					model: Stats.coreUsage

					delegate: Row {
						required property int index
						required property var modelData

						width: coreColumn.width
						height: 16
						spacing: 8

						Text {
							width: 44
							text: "CPU " + index
							color: Colors.muted
							font.family: "CaskaydiaCove Nerd Font Propo"
							font.pixelSize: 10
							font.weight: Font.DemiBold
						}

						Rectangle {
							id: coreBar

							anchors.verticalCenter: parent.verticalCenter
							width: parent.width - 44 - 38 - 16
							height: 4
							radius: 2
							color: Qt.alpha(Colors.foreground, 0.18)

							Rectangle {
								width: coreBar.width * Math.max(0, Math.min(100, modelData)) / 100
								height: parent.height
								radius: parent.radius
								color: modelData >= 90 ? Colors.color2 : (modelData >= 65 ? Colors.warning : Colors.accent)
							}
						}

						Text {
							width: 38
							text: Math.round(modelData) + "%"
							color: Colors.foreground
							horizontalAlignment: Text.AlignRight
							font.family: "CaskaydiaCove Nerd Font Propo"
							font.pixelSize: 10
							font.weight: Font.DemiBold
						}
					}
				}
			}
		}
	}

	BarChunk {
		text: " CPU " + Stats.cpu + "%"
		color: Stats.cpu >= 90 ? Colors.color2 : (Stats.cpu >= 65 ? Colors.warning : Colors.foreground)
	}

	BarChunk {
		text: " MEM " + Stats.memUsed.toFixed(1) + "G"
		color: Stats.memPct >= 90 ? Colors.color2 : (Stats.memPct >= 65 ? Colors.warning : Colors.foreground)
	}

	BarChunk {
		text: " " + root.temperatureIcon(Stats.temp) + " " + Stats.temp + "°"
		color: Stats.temp >= 80 ? Colors.color2 : (Stats.temp >= 65 ? Colors.warning : Colors.foreground)
	}

	BarChunk {
		text: "  " + Stats.load
		color: Colors.foreground
	}

}
