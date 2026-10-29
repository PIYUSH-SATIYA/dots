import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland

Scope {
	id: root

	NotificationServer {
		id: server

		keepOnReload: true
		bodySupported: true
		actionsSupported: true
		imageSupported: true
		onNotification: notification => NotificationHub.register(notification)
	}

	Component.onCompleted: NotificationHub.server = server

	PanelWindow {
		id: toastWindow

		visible: NotificationHub.toasts.length > 0 && !NotificationHub.centerOpen
		anchors {
			top: true
			right: true
		}
		margins {
			top: 36
			right: 8
		}
		implicitWidth: 400
		implicitHeight: toastColumn.implicitHeight + 16
		exclusiveZone: 0
		focusable: false
		color: "transparent"
		WlrLayershell.namespace: "quickshell-notifications"
		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

		Column {
			id: toastColumn

			anchors {
				left: parent.left
				right: parent.right
				top: parent.top
			}
			spacing: 8

			Repeater {
				model: NotificationHub.toasts

				delegate: NotificationCard {
					required property var modelData

					width: toastColumn.width
					notification: modelData
					popup: true
				}
			}
		}
	}

	PanelWindow {
		id: centerWindow

		visible: NotificationHub.centerOpen
		anchors {
			top: true
			right: true
		}
		margins {
			top: 36
			right: 8
		}
		implicitWidth: 420
		implicitHeight: 640
		exclusiveZone: 0
		focusable: true
		aboveWindows: true
		color: "transparent"
		WlrLayershell.namespace: "quickshell-notification-center"
		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

		Rectangle {
			anchors.fill: parent
			radius: 14
			color: Qt.alpha(Colors.color0, 0.82)
			border.width: 1
			border.color: Colors.separator

			Shortcut {
				sequence: "Escape"
				context: Qt.WindowShortcut
				onActivated: NotificationHub.centerOpen = false
			}

			Column {
				anchors {
					fill: parent
					margins: 14
				}
				spacing: 12

				Row {
					width: parent.width
					height: 30
					spacing: 10

					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: "Notifications"
						color: Colors.foreground
						font.family: "CaskaydiaCove Nerd Font Propo"
						font.pixelSize: 16
						font.weight: Font.DemiBold
					}

					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: NotificationHub.count > 0 ? NotificationHub.count : ""
						color: Colors.accent
						font.family: "CaskaydiaCove Nerd Font Propo"
						font.pixelSize: 13
						font.weight: Font.DemiBold
					}

					Item {
						width: parent.width - 150
					}

					Item {
						width: 24
						height: 24

						Text {
							anchors.centerIn: parent
							text: "󰅖"
							color: closeMouse.containsMouse ? Colors.color1 : Colors.muted
							font.family: "CaskaydiaCove Nerd Font Propo"
							font.pixelSize: 16
						}

						MouseArea {
							id: closeMouse

							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							hoverEnabled: true
							onClicked: NotificationHub.centerOpen = false
						}
					}
				}

				Item {
					width: parent.width
					height: parent.height - 30 - 28 - 24

					ListView {
						anchors.fill: parent
						model: NotificationHub.tracked.slice().reverse()
						spacing: 8
						clip: true
						boundsBehavior: Flickable.StopAtBounds

						delegate: NotificationCard {
							required property var modelData

							width: ListView.view.width
							notification: modelData
						}
					}

					Text {
						anchors.centerIn: parent
						visible: NotificationHub.count === 0
						text: "No Notifications"
						color: Colors.muted
						font.family: "CaskaydiaCove Nerd Font Propo"
						font.pixelSize: 13
						font.weight: Font.DemiBold
					}
				}

				Row {
					width: parent.width
					height: 28
					spacing: 8

					Rectangle {
						width: dndLabel.implicitWidth + 20
						height: 28
						radius: 6
						color: NotificationHub.dnd ? Qt.alpha(Colors.accent, 0.2) : Qt.alpha(Colors.foreground, 0.08)

						Text {
							id: dndLabel

							anchors.centerIn: parent
							text: NotificationHub.dnd ? "Do Not Disturb: On" : "Do Not Disturb: Off"
							color: NotificationHub.dnd ? Colors.accent : Colors.foreground
							font.family: "CaskaydiaCove Nerd Font Propo"
							font.pixelSize: 11
							font.weight: Font.DemiBold
						}

						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							onClicked: NotificationHub.toggleDnd()
						}
					}

					Rectangle {
						width: clearLabel.implicitWidth + 20
						height: 28
						radius: 6
						color: clearMouse.containsMouse ? Qt.alpha(Colors.color1, 0.2) : Qt.alpha(Colors.foreground, 0.08)

						Text {
							id: clearLabel

							anchors.centerIn: parent
							text: "Clear All"
							color: clearMouse.containsMouse ? Colors.color1 : Colors.foreground
							font.family: "CaskaydiaCove Nerd Font Propo"
							font.pixelSize: 11
							font.weight: Font.DemiBold
						}

						MouseArea {
							id: clearMouse

							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							hoverEnabled: true
							onClicked: NotificationHub.clearAll()
						}
					}
				}
			}
		}
	}

	IpcHandler {
		target: "notifications"

		function toggleCenter() {
			NotificationHub.toggleCenter()
		}

		function openCenter() {
			NotificationHub.centerOpen = true
		}

		function closeCenter() {
			NotificationHub.centerOpen = false
		}

		function toggleDnd() {
			NotificationHub.toggleDnd()
		}

		function closeLatest() {
			NotificationHub.closeLatest()
		}

		function clearAll() {
			NotificationHub.clearAll()
		}
	}
}
