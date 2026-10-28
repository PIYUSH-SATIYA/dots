import QtQuick
import Quickshell.Services.UPower

BarChunk {
	id: root

	readonly property int profile: PowerProfiles.profile

	text: root.profile === PowerProfile.Performance ? "󰓅" : (root.profile === PowerProfile.PowerSaver ? "󰌪" : "󰾅")
	color: root.profile === PowerProfile.Performance ? Colors.accent : (root.profile === PowerProfile.PowerSaver ? Colors.color5 : Colors.color2)

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: PowerProfiles.profile = (PowerProfiles.profile + 1) % 3
	}

}
