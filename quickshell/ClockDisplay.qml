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

	function buildMonth(year, month, today) {
		const first = new Date(year, month, 1)
		const offset = (first.getDay() + 6) % 7
		const days = []

		for (let index = 0; index < 42; ++index) {
			const date = new Date(year, month, 1 - offset + index)
			const inMonth = date.getMonth() === month
			days.push({
				day: inMonth ? date.getDate() : 0,
				today: inMonth && root.sameDay(date, today),
			})
		}

		return {
			name: Qt.formatDateTime(first, "MMMM"),
			days: days,
		}
	}

	function buildYear(now) {
		const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
		const months = []

		for (let month = 0; month < 12; ++month)
			months.push(root.buildMonth(now.getFullYear(), month, today))

		return months
	}

	readonly property var calendarMonths: root.buildYear(clock.date)
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
		anchor.edges: Edges.Bottom
		anchor.gravity: Edges.Bottom
		anchor.margins.top: 4
		anchor.adjustment: PopupAdjustment.Slide
		implicitWidth: 664
		implicitHeight: 452
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

				Text {
					width: parent.width
					text: clock.date.getFullYear()
					color: Colors.accent
					horizontalAlignment: Text.AlignHCenter
					font.family: "CaskaydiaCove Nerd Font Propo"
					font.pixelSize: 12
					font.weight: Font.DemiBold
				}

				Grid {
					width: parent.width
					columns: 4
					rows: 3
					columnSpacing: 12
					rowSpacing: 10

					Repeater {
						model: root.calendarMonths

						delegate: Column {
							required property var modelData

							width: 150
							spacing: 2

							Text {
								width: parent.width
								text: modelData.name
								color: Colors.foreground
								horizontalAlignment: Text.AlignHCenter
								font.family: "CaskaydiaCove Nerd Font Propo"
								font.pixelSize: 10
								font.weight: Font.DemiBold
							}

							Row {
								width: parent.width
								height: 12

								Repeater {
									model: root.weekdayLabels

									delegate: Text {
										required property var modelData

										width: parent.width / 7
										text: modelData
										color: Colors.muted
										horizontalAlignment: Text.AlignHCenter
										font.family: "CaskaydiaCove Nerd Font Propo"
										font.pixelSize: 7
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
									model: modelData.days

									delegate: Rectangle {
										required property var modelData

										width: parent.width / 7
										height: 15
										radius: 3
										color: modelData.today ? Qt.alpha(Colors.accent, 0.24) : "transparent"

										Text {
											anchors.centerIn: parent
											text: modelData.day > 0 ? modelData.day : ""
											color: modelData.today ? Colors.accent : Colors.foreground
											font.family: "CaskaydiaCove Nerd Font Propo"
											font.pixelSize: 9
											font.weight: modelData.today ? Font.Bold : Font.DemiBold
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
