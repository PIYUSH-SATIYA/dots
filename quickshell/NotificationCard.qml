import QtQuick
import Quickshell.Services.Notifications
import Quickshell.Widgets

Rectangle {
	id: root

	property var notification
	property bool popup: false

	readonly property bool critical: root.notification && root.notification.urgency === NotificationUrgency.Critical
	readonly property bool low: root.notification && root.notification.urgency === NotificationUrgency.Low

	implicitHeight: layout.implicitHeight + 20
	radius: 10
	color: Qt.alpha(Colors.color0, 0.94)
	border.width: 1
	border.color: root.critical ? Colors.color1 : Colors.separator

	Rectangle {
		anchors {
			left: parent.left
			top: parent.top
			bottom: parent.bottom
		}

		width: 4
		radius: 2
		color: root.critical ? Colors.color1 : (root.low ? Colors.color7 : Colors.color3)
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: NotificationHub.invokeDefault(root.notification)
	}

	Column {
		id: layout

		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
			margins: 12
			leftMargin: 16
		}

		spacing: 8

		Row {
			width: parent.width
			spacing: 10

			Item {
				width: 28
				height: 28

				IconImage {
					anchors.fill: parent
					source: root.notification ? root.notification.appIcon : ""
					visible: source !== ""
				}

				Text {
					anchors.centerIn: parent
					visible: !root.notification || root.notification.appIcon === ""
					text: "󰂚"
					color: Colors.accent
					font.family: "CaskaydiaCove Nerd Font Propo"
					font.pixelSize: 18
				}
			}

			Column {
				width: parent.width - 28 - 28 - 20
				spacing: 2

				Text {
					width: parent.width
					text: root.notification ? root.notification.appName : ""
					color: Colors.muted
					elide: Text.ElideRight
					textFormat: Text.PlainText
					font.family: "CaskaydiaCove Nerd Font Propo"
					font.pixelSize: 11
					font.weight: Font.DemiBold
					visible: text !== ""
				}

				Text {
					width: parent.width
					text: root.notification ? root.notification.summary : ""
					color: Colors.foreground
					elide: Text.ElideRight
					textFormat: Text.PlainText
					maximumLineCount: 2
					wrapMode: Text.Wrap
					font.family: "CaskaydiaCove Nerd Font Propo"
					font.pixelSize: 13
					font.weight: Font.DemiBold
				}

				Text {
					width: parent.width
					text: root.notification ? root.notification.body : ""
					color: Colors.foreground
					opacity: 0.75
					elide: Text.ElideRight
					maximumLineCount: 3
					wrapMode: Text.Wrap
					textFormat: Text.PlainText
					font.family: "CaskaydiaCove Nerd Font Propo"
					font.pixelSize: 12
					visible: text !== ""
				}
			}

			Item {
				width: 20
				height: 20

				Text {
					anchors.centerIn: parent
					text: "󰅖"
					color: closeMouse.containsMouse ? Colors.color1 : Colors.muted
					font.family: "CaskaydiaCove Nerd Font Propo"
					font.pixelSize: 14
				}

				MouseArea {
					id: closeMouse

					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					hoverEnabled: true
					onClicked: {
						if (root.notification)
							root.notification.dismiss()
					}
				}
			}
		}

		Image {
			width: parent.width
			height: root.notification && root.notification.image !== "" ? 120 : 0
			visible: height > 0
			source: root.notification ? root.notification.image : ""
			fillMode: Image.PreserveAspectCrop
			asynchronous: true
			clip: true
		}

		Flow {
			width: parent.width
			spacing: 6
			visible: root.notification && root.notification.actions.length > 0

			Repeater {
				model: root.notification ? root.notification.actions : []

				delegate: Rectangle {
					required property var modelData

					width: actionLabel.implicitWidth + 16
					height: 24
					radius: 6
					color: actionMouse.containsMouse ? Qt.alpha(Colors.accent, 0.2) : Qt.alpha(Colors.foreground, 0.08)

					Text {
						id: actionLabel

						anchors.centerIn: parent
						text: parent.modelData.text
						color: Colors.foreground
						textFormat: Text.PlainText
						font.family: "CaskaydiaCove Nerd Font Propo"
						font.pixelSize: 11
						font.weight: Font.DemiBold
					}

					MouseArea {
						id: actionMouse

						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
						hoverEnabled: true
						onClicked: parent.modelData.invoke()
					}
				}
			}
		}
	}

	Timer {
		interval: root.popup ? NotificationHub.toastTimeout(root.notification) : 0
		running: root.popup && interval > 0
		onTriggered: {
			if (root.notification)
				root.notification.expire()
		}
	}

	Connections {
		target: root.notification

		function onClosed(reason) {
			NotificationHub.removeToast(root.notification)
		}
	}
}
