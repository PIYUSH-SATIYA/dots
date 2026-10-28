import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

BarChunk {
	id: root

	readonly property var sink: Pipewire.defaultAudioSink
	readonly property var audio: root.sink ? root.sink.audio : null
	readonly property bool muted: root.audio ? root.audio.muted : false
	readonly property int volume: root.audio ? Math.round(root.audio.volume * 100) : 0

	function volumeIcon(value) {
		if (value <= 0)
			return "󰕿"

		if (value < 50)
			return "󰖀"

		return "󰕾"
	}

	visible: root.sink !== null
	text: root.muted ? "󰝟" : root.volumeIcon(root.volume)
	color: root.muted ? Colors.muted : Colors.foreground

	MouseArea {
		id: audioMouse

		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: (mouse) => {
			if (!root.audio)
				return

			if (mouse.button === Qt.LeftButton)
				root.audio.muted = !root.audio.muted
			else
				Quickshell.execDetached(["pavucontrol", "-t", "4"])
		}
		onWheel: (wheel) => {
			if (!root.audio)
				return

			const step = wheel.angleDelta.y > 0 ? 0.02 : -0.02
			root.audio.volume = Math.max(0, Math.min(1.5, root.audio.volume + step))
		}
	}

}
