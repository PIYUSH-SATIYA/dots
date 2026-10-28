import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
	id: bar

	anchors {
		top: true
		left: true
		right: true
	}

	implicitHeight: 28
	exclusiveZone: 28
	color: "transparent"

	WlrLayershell.namespace: "quickshell-bar"

	readonly property var workspaces: {
		const byId = {}
		for (const ws of Hyprland.workspaces.values) {
			if (ws.id > 0)
				byId[ws.id] = ws
		}
		const list = []
		for (let id = 1; id <= 5; ++id) {
			list.push(byId[id] ?? {
				id: id,
				name: String(id),
				focused: false,
				active: false
			})
		}
		return list
	}

	function activateWorkspace(id) {
		if (Hyprland.usingLua)
			Hyprland.dispatch('hl.dsp.focus({ workspace = "' + id + '" })')
		else
			Hyprland.dispatch("workspace " + id)
	}

	Rectangle {
		anchors.fill: parent
		color: Qt.alpha(Colors.background, 0.4)

		Row {
			id: workspaces

			anchors {
				left: parent.left
				verticalCenter: parent.verticalCenter
			}

			Repeater {
				model: bar.workspaces

				delegate: Item {
					id: workspace

					required property var modelData

					implicitWidth: workspaceLabel.implicitWidth + 12
					implicitHeight: bar.height

					Text {
						id: workspaceLabel

						anchors.centerIn: parent
						text: workspace.modelData.id
						color: workspace.modelData.focused ? Colors.accent : (workspace.modelData.active ? Colors.foreground : Colors.muted)
						font.family: "CaskaydiaCove Nerd Font Propo"
						font.pixelSize: 13
						font.weight: Font.DemiBold
					}

					Rectangle {
						anchors {
							left: parent.left
							right: parent.right
							bottom: parent.bottom
						}

						height: 2
						color: Colors.accent
						visible: workspace.modelData.focused
					}

					MouseArea {
						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
						onClicked: bar.activateWorkspace(workspace.modelData.id)
					}
				}
			}
		}

		SystemClock {
			id: clock
			precision: SystemClock.Minutes
		}

		Text {
			id: clockLabel

			anchors.centerIn: parent
			text: Qt.formatDateTime(clock.date, "HH:mm")
			color: Colors.foreground
			font.family: "CaskaydiaCove Nerd Font Propo"
			font.pixelSize: 13
			font.weight: Font.DemiBold
		}

		Text {
			id: shellLabel

			anchors {
				right: parent.right
				rightMargin: 10
				verticalCenter: parent.verticalCenter
			}

			text: "QS"
			color: Colors.accent
			font.family: "CaskaydiaCove Nerd Font Propo"
			font.pixelSize: 13
			font.weight: Font.DemiBold
		}
	}
}
