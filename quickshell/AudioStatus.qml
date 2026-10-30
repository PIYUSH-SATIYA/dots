import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

BarChunk {
	id: root

	readonly property var sink: Pipewire.defaultAudioSink
	readonly property bool muted: Stats.muted
	readonly property int volume: Stats.volume

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
			if (mouse.button === Qt.LeftButton) {
				Osd.toggleMute()
			} else {
				Quickshell.execDetached(["pavucontrol", "-t", "4"])
			}
		}
		onWheel: (wheel) => {
			Osd.adjustVolume(wheel.angleDelta.y > 0 ? 2 : -2)
		}
	}

}
