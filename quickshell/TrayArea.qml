import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Item {
	id: root

	property var window: null
	readonly property var items: SystemTray.items.values

	implicitWidth: row.implicitWidth + 24
	implicitHeight: 28
	visible: root.items.length > 0

	Row {
		id: row

		anchors.centerIn: parent
		spacing: 10

		Repeater {
			model: root.items

			delegate: IconImage {
				id: trayIcon

				required property var modelData

				implicitSize: 13
				source: modelData.icon
				opacity: modelData.status === Status.NeedsAttention ? 1 : 0.85

				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton | Qt.RightButton
					cursorShape: Qt.PointingHandCursor
					onClicked: (mouse) => {
						if (mouse.button === Qt.LeftButton) {
							trayIcon.modelData.activate()
						} else if (trayIcon.modelData.hasMenu && root.window) {
							const position = trayIcon.mapToItem(null, 0, 0)
							trayIcon.modelData.display(root.window, position.x, position.y)
						} else {
							trayIcon.modelData.secondaryActivate()
						}
					}
					onWheel: (wheel) => {
						return trayIcon.modelData.scroll(wheel.angleDelta.y, false)
					}
				}

			}

		}

	}

}
