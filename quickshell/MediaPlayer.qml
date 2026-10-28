import QtQuick
import Quickshell.Services.Mpris

BarChunk {
	id: root

	readonly property var player: {
		const players = Mpris.players.values
		for (const entry of players) {
			if (entry.isPlaying)
				return entry

		}
		return players.length > 0 ? players[0] : null
	}

	function displayText() {
		if (!root.player)
			return ""

		const artist = root.player.trackArtist ? root.player.trackArtist + " - " : ""
		const title = artist + (root.player.trackTitle || "")
		return title.length > 35 ? title.substring(0, 35) + "…" : title
	}

	visible: root.player !== null && root.text.length > 0
	text: root.displayText()
	color: root.player && !root.player.isPlaying ? Colors.muted : Colors.foreground
	opacity: root.player && !root.player.isPlaying ? 0.6 : 1

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: (mouse) => {
			if (!root.player)
				return

			if (mouse.button === Qt.LeftButton)
				root.player.togglePlaying()
			else
				root.player.stop()
		}
		onWheel: (wheel) => {
			if (!root.player)
				return

			if (wheel.angleDelta.y > 0)
				root.player.previous()
			else
				root.player.next()
		}
	}

}
