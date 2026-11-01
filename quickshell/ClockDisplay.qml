import QtQuick
import Quickshell

BarChunk {
	id: root

	property bool alternate: false
	property bool calendarOpen: false

	function sameDay(left, right) {
		return left.getFullYear() === right.getFullYear()
			&& left.getMonth() === right.getMonth()
			&& left.getDate() === right.getDate()
	}

	function buildCalendar(now) {
		const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
		const first = new Date(today.getFullYear(), today.getMonth(), 1)
		const offset = (first.getDay() + 6) % 7
		const start = new Date(first)
		start.setDate(1 - offset)

		const days = []

		for (let index = 0; index < 42; ++index) {
			const day = new Date(start)
			day.setDate(start.getDate() + index)
			days.push({
				day: day.getDate(),
				inMonth: day.getMonth() === today.getMonth(),
				today: root.sameDay(day, today),
			})
		}

		return days
	}

	readonly property var calendarDays: root.buildCalendar(clock.date)
	readonly property var weekdayLabels: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

	text: root.alternate ? Qt.formatDateTime(clock.date, "ddd dd MMM yyyy") : Qt.formatDateTime(clock.date, "HH:mm")
	horizontalPadding: 15
	divider: false

	SystemClock {
		id: clock

		precision: SystemClock.Minutes
	}

	Timer {
		id: calendarCloseTimer

		interval: 220
		onTriggered: root.calendarOpen = false
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		hoverEnabled: true
		onEntered: {
			calendarCloseTimer.stop()
			root.calendarOpen = true
		}
		onExited: calendarCloseTimer.restart()
		onClicked: (mouse) => {
			if (mouse.button === Qt.LeftButton)
				root.alternate = !root.alternate
			else
				Quickshell.execDetached(["kitty", "--class=peaclock", "-e", "peaclock"])
		}
	}

	PopupWindow {
		id: calendarPopup

		visible: root.calendarOpen
		anchor.item: root
		anchor.edges: Edges.Bottom | Edges.Right
		anchor.gravity: Edges.Bottom | Edges.Right
		anchor.margins.top: 4
		anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide
		implicitWidth: 286
		implicitHeight: 300
		color: "transparent"
		grabFocus: false

		Rectangle {
			anchors.fill: parent
			radius: 12
			color: Qt.alpha(Colors.color0, 0.97)
			border.width: 1
			border.color: Colors.separator

			HoverHandler {
				onHoveredChanged: {
					if (hovered)
						calendarCloseTimer.stop()
					else
						calendarCloseTimer.restart()
				}
			}

			Column {
				anchors {
					fill: parent
					margins: 14
				}
				spacing: 10

				Row {
					width: parent.width
					height: 24

					Text {
						text: Qt.formatDateTime(clock.date, "MMMM yyyy")
						color: Colors.foreground
						font.family: "CaskaydiaCove Nerd Font Propo"
						font.pixelSize: 14
						font.weight: Font.DemiBold
					}

					Item {
						width: parent.width - 160
					}

					Text {
						text: Qt.formatDateTime(clock.date, "ddd dd")
						color: Colors.accent
						font.family: "CaskaydiaCove Nerd Font Propo"
						font.pixelSize: 11
						font.weight: Font.DemiBold
					}
				}

				Row {
					width: parent.width
					height: 22
					spacing: 0

					Repeater {
						model: root.weekdayLabels

						delegate: Text {
							required property var modelData

							width: parent.width / 7
							text: modelData
							color: Colors.muted
							horizontalAlignment: Text.AlignHCenter
							font.family: "CaskaydiaCove Nerd Font Propo"
							font.pixelSize: 10
							font.weight: Font.DemiBold
						}
					}
				}

				Grid {
					width: parent.width
					columns: 7
					rows: 6
					columnSpacing: 0
					rowSpacing: 1

					Repeater {
						model: root.calendarDays

						delegate: Rectangle {
							required property var modelData

							width: parent.width / 7
							height: 31
							radius: 6
							color: modelData.today ? Qt.alpha(Colors.accent, 0.24) : "transparent"

							Text {
								anchors.centerIn: parent
								text: modelData.day
								color: modelData.today ? Colors.accent : (modelData.inMonth ? Colors.foreground : Colors.muted)
								opacity: modelData.inMonth ? 1 : 0.4
								font.family: "CaskaydiaCove Nerd Font Propo"
								font.pixelSize: 12
								font.weight: modelData.today ? Font.Bold : Font.DemiBold
							}
						}
					}
				}
			}
		}
	}
}
