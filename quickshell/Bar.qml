import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
	id: bar

	implicitHeight: 28
	exclusiveZone: 28
	color: "transparent"
	WlrLayershell.namespace: "quickshell-bar"

	anchors {
		top: true
		left: true
		right: true
	}

	Rectangle {
		anchors.fill: parent
		color: Qt.alpha(Colors.color0, 0.4)

		Row {
			anchors {
				left: parent.left
				verticalCenter: parent.verticalCenter
			}

			WorkspaceSwitcher {}

			Rectangle {
				anchors.verticalCenter: parent.verticalCenter

				width: 1
				height: 14
				color: Colors.separator
			}

			MediaPlayer {}
		}

		ClockDisplay {
			anchors.centerIn: parent
		}

		Row {
			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}

			SystemMetrics {}
			BatteryStatus {}
			PowerProfileStatus {}
			BluetoothStatus {}
			AudioStatus {}
			BrightnessStatus {}
			NetworkStatus {}
			TrayArea {
				window: bar
			}
			BarActions {}
		}
	}
}
