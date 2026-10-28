pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property int cpu: 0
	property string cores: ""
	property real memUsed: 0
	property real memTotal: 0
	property int memPct: 0
	property int temp: 0
	property string load: "0.00"
	property string wifiState: "disconnected"
	property string wifiSsid: ""
	property int wifiSignal: 0
	property int brightness: 0
	readonly property bool wifiConnected: root.wifiState === "connected"

	Component.onCompleted: statsProcess.running = true

	Process {
		id: statsProcess

		command: ["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/bar-stats.sh"]
		onExited: statsTimer.start()

		stdout: StdioCollector {
			onStreamFinished: {
				const text = this.text.trim()
				if (!text)
					return

				try {
					const data = JSON.parse(text)
					root.cpu = data.cpu
					root.cores = data.cores
					root.memUsed = data.mem_used
					root.memTotal = data.mem_total
					root.memPct = data.mem_pct
					root.temp = data.temp
					root.load = data.load
					root.wifiState = data.wifi_state
					root.wifiSsid = data.wifi_ssid
					root.wifiSignal = data.wifi_signal
					root.brightness = data.brightness
				} catch (error) {
					console.warn("Failed to parse bar stats:", error)
				}
			}
		}

	}

	Timer {
		id: statsTimer

		interval: 2000
		onTriggered: statsProcess.running = true
	}

}
