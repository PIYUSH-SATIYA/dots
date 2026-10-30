import QtQuick
import Quickshell.Services.Mpris
import Quickshell.Widgets

Item {
	id: root

	readonly property var player: {
		const players = Mpris.players.values
		for (const entry of players) {
			if (entry.isPlaying)
				return entry
		}
		return players.length > 0 ? players[0] : null
	}

	visible: root.player !== null
	implicitHeight: root.visible ? 78 : 0
	height: implicitHeight

	Rectangle {
		anchors.fill: parent
		radius: 10
		color: Qt.alpha(Colors.color0, 0.55)
		border.width: 1
		border.color: Colors.separator

		Row {
			anchors {
				fill: parent
				margins: 10
			}
			spacing: 12

			Item {
				width: 54
				height: 54

				Image {
					id: artwork

					anchors.fill: parent
					source: root.player && root.player.trackArtUrl ? root.player.trackArtUrl : ""
					fillMode: Image.PreserveAspectCrop
					asynchronous: true
					clip: true
					visible: source !== ""
				}

				Rectangle {
					anchors.fill: parent
					visible: artwork.source === ""
					radius: 8
					color: Qt.alpha(Colors.foreground, 0.08)

					Text {
						anchors.centerIn: parent
						text: "󰎆"
						color: Colors.muted
						font.family: "CaskaydiaCove Nerd Font Propo"
						font.pixelSize: 24
					}
				}
			}

			Column {
				width: parent.width - 54 - 72 - 24
				anchors.verticalCenter: parent.verticalCenter
				spacing: 2

				Text {
					width: parent.width
					text: root.player ? (root.player.trackTitle || "Unknown Title") : ""
					color: Colors.foreground
					elide: Text.ElideRight
					textFormat: Text.PlainText
					font.family: "CaskaydiaCove Nerd Font Propo"
					font.pixelSize: 13
					font.weight: Font.DemiBold
				}

				Text {
					width: parent.width
					text: root.player ? (root.player.trackArtist || "Unknown Artist") : ""
					color: Colors.muted
					elide: Text.ElideRight
					textFormat: Text.PlainText
					font.family: "CaskaydiaCove Nerd Font Propo"
					font.pixelSize: 11
					font.weight: Font.DemiBold
				}

				Text {
					width: parent.width
					text: root.player ? (root.player.trackAlbum || "") : ""
					color: Colors.muted
					elide: Text.ElideRight
					textFormat: Text.PlainText
					font.family: "CaskaydiaCove Nerd Font Propo"
					font.pixelSize: 10
					visible: text !== ""
				}
			}

			Row {
				width: 72
				anchors.verticalCenter: parent.verticalCenter
				spacing: 4

				Item {
					width: 20
					height: 24

					Text {
						anchors.centerIn: parent
						text: "󰒮"
						color: previousMouse.containsMouse ? Colors.accent : Colors.foreground
						font.family: "CaskaydiaCove Nerd Font Propo"
						font.pixelSize: 17
					}

					MouseArea {
						id: previousMouse

						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
						hoverEnabled: true
						onClicked: {
							if (root.player)
								root.player.previous()
						}
					}
				}

				Item {
					width: 24
					height: 24

					Text {
						anchors.centerIn: parent
						text: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
						color: playMouse.containsMouse ? Colors.accent : Colors.foreground
						font.family: "CaskaydiaCove Nerd Font Propo"
						font.pixelSize: 20
					}

					MouseArea {
						id: playMouse

						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
						hoverEnabled: true
						onClicked: {
							if (root.player)
								root.player.togglePlaying()
						}
					}
				}

				Item {
					width: 20
					height: 24

					Text {
						anchors.centerIn: parent
						text: "󰒭"
						color: nextMouse.containsMouse ? Colors.accent : Colors.foreground
						font.family: "CaskaydiaCove Nerd Font Propo"
						font.pixelSize: 17
					}

					MouseArea {
						id: nextMouse

						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
						hoverEnabled: true
						onClicked: {
							if (root.player)
								root.player.next()
						}
					}
				}
			}
		}
	}
}
