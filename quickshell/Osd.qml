pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property bool visible: false
	property string icon: ""
	property real value: 0
	property string text: ""
	property int duration: 1000
	property var volumeQueue: []
	property bool volumeRunning: false
	property var brightnessQueue: []
	property bool brightnessRunning: false

	function volumeIcon(level, muted) {
		if (muted)
			return "󰝟"

		if (level <= 0)
			return "󰕿"

		if (level < 50)
			return "󰖀"

		return "󰕾"
	}

	function brightnessIcon(level) {
		if (level >= 75)
			return "󰃠"

		if (level >= 50)
			return "󰃟"

		if (level >= 25)
			return "󰃝"

		return "󰃞"
	}

	function show(icon, value, text) {
		root.icon = icon
		root.value = Math.max(0, Math.min(1, value))
		root.text = text
		root.visible = true
		hideTimer.restart()
	}

	function showVolumeState(level, muted) {
		const percent = Math.max(0, Math.min(150, Math.round(level)))
		root.show(root.volumeIcon(percent, muted), percent / 100, muted ? "Muted" : percent + "%")
	}

	function enqueueVolume(job) {
		root.volumeQueue.push(job)

		if (!root.volumeRunning)
			root.runVolume()
	}

	function runVolume() {
		if (root.volumeQueue.length === 0) {
			root.volumeRunning = false
			return
		}

		const job = root.volumeQueue.shift()
		root.volumeRunning = true
		volumeProcess.action = job.action
		volumeProcess.step = job.step
		volumeProcess.running = true
	}

	function adjustVolume(step) {
		const amount = Math.abs(Number(step)) || 5
		root.enqueueVolume({
			action: Number(step) >= 0 ? "up" : "down",
			step: amount,
		})
	}

	function toggleMute() {
		root.enqueueVolume({
			action: "mute",
			step: 0,
		})
	}

	function setVolume(level) {
		const percent = Math.max(0, Math.min(150, Math.round(level)))
		root.enqueueVolume({
			action: "set",
			step: percent,
		})
	}

	function showBrightness(level) {
		const percent = Math.max(0, Math.min(100, Math.round(level)))
		root.show(root.brightnessIcon(percent), percent / 100, percent + "%")
	}

	function adjustBrightness(direction, step) {
		root.brightnessQueue.push({
			direction: direction,
			step: Math.abs(Number(step)) || 5,
		})

		if (!root.brightnessRunning)
			root.runBrightness()
	}

	function setBrightness(level) {
		const percent = Math.max(10, Math.min(100, Math.round(level)))
		root.brightnessQueue.push({
			direction: "set",
			step: percent,
		})

		if (!root.brightnessRunning)
			root.runBrightness()
	}

	function runBrightness() {
		if (root.brightnessQueue.length === 0) {
			root.brightnessRunning = false
			return
		}

		const job = root.brightnessQueue.shift()
		root.brightnessRunning = true
		brightnessProcess.direction = job.direction
		brightnessProcess.step = job.step
		brightnessProcess.running = true
	}

	Timer {
		id: hideTimer

		interval: root.duration
		onTriggered: root.visible = false
	}

	Process {
		id: volumeProcess

		property string action: "get"
		property int step: 5

		command: [
			"bash",
			Quickshell.env("HOME") + "/.config/quickshell/scripts/osd-volume.sh",
			volumeProcess.action,
			String(volumeProcess.step),
		]

		stdout: StdioCollector {
			onStreamFinished: {
				const parts = this.text.trim().split(":")
				if (parts.length !== 2)
					return

				const level = Number(parts[0])
				if (Number.isNaN(level))
					return

				root.showVolumeState(level, parts[1] === "1")
			}
		}

		onExited: root.runVolume()
	}

	Process {
		id: brightnessProcess

		property string direction: "up"
		property int step: 5

		command: [
			"bash",
			Quickshell.env("HOME") + "/.config/quickshell/scripts/osd-brightness.sh",
			brightnessProcess.direction,
			String(brightnessProcess.step),
		]

		stdout: StdioCollector {
			onStreamFinished: {
				const level = Number(this.text.trim())
				if (!Number.isNaN(level))
					root.showBrightness(level)
			}
		}

		onExited: root.runBrightness()
	}
}
