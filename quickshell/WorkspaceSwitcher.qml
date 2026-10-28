import QtQuick
import Quickshell.Hyprland

Row {
	id: root

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
				active: false,
				empty: true
			})
		}
		return list
	}

	function focusWorkspace(name) {
		if (Hyprland.usingLua)
			Hyprland.dispatch('hl.dsp.focus({ workspace = "' + name + '" })')
		else
			Hyprland.dispatch("workspace " + name)
	}

	Item {
		width: 10
		height: 1
	}

	Repeater {
		model: root.workspaces

		delegate: Item {
			id: workspace

			required property var modelData

			implicitWidth: workspaceLabel.implicitWidth + 12
			implicitHeight: 28

			Rectangle {
				anchors.fill: parent
				color: workspace.modelData.focused
					? Qt.alpha(Colors.accent, 0.15)
					: (workspaceMouse.containsMouse ? Qt.alpha(Colors.foreground, 0.08) : "transparent")
			}

			Text {
				id: workspaceLabel

				anchors.centerIn: parent
				text: workspace.modelData.id
				color: workspace.modelData.focused
					? Colors.accent
					: (workspace.modelData.active ? Colors.color7 : Colors.muted)
				opacity: workspace.modelData.empty ? 0.45 : 1
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
				id: workspaceMouse

				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				hoverEnabled: true
				onClicked: root.focusWorkspace(workspace.modelData.id)
				onWheel: wheel => root.focusWorkspace(wheel.angleDelta.y > 0 ? "e-1" : "e+1")
			}
		}
	}

	Item {
		width: 10
		height: 1
	}
}
