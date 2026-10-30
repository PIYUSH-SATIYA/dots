import QtQuick

Item {
	id: root

	property real value: 0
	property real from: 0
	property real to: 100
	property real stepSize: 1
	property bool dragging: false
	property real dragValue: 0

	readonly property real displayValue: root.dragging ? root.dragValue : root.value
	readonly property real ratio: Math.max(0, Math.min(1, (root.displayValue - root.from) / Math.max(1, root.to - root.from)))

	signal moved(real value)
	signal released(real value)

	implicitHeight: 20

	function valueAt(x) {
		const raw = root.from + (root.to - root.from) * Math.max(0, Math.min(1, x / Math.max(1, root.width)))
		return Math.max(root.from, Math.min(root.to, Math.round(raw / root.stepSize) * root.stepSize))
	}

	Rectangle {
		anchors {
			left: parent.left
			right: parent.right
			verticalCenter: parent.verticalCenter
		}
		height: 6
		radius: 3
		color: Qt.alpha(Colors.foreground, 0.22)
	}

	Rectangle {
		anchors {
			left: parent.left
			verticalCenter: parent.verticalCenter
		}
		width: parent.width * root.ratio
		height: 6
		radius: 3
		color: Colors.foreground
	}

	Rectangle {
		x: (parent.width - width) * root.ratio
		anchors.verticalCenter: parent.verticalCenter
		width: root.dragging ? 14 : 12
		height: root.dragging ? 14 : 12
		radius: width / 2
		color: Colors.foreground
	}

	MouseArea {
		id: mouse

		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true
		onPressed: (event) => {
			root.dragging = true
			root.dragValue = root.valueAt(event.x)
		}
		onPositionChanged: (event) => {
			if (root.dragging) {
				root.dragValue = root.valueAt(event.x)
				root.moved(root.dragValue)
			}
		}
		onReleased: (event) => {
			root.dragValue = root.valueAt(event.x)
			root.dragging = false
			root.released(root.dragValue)
		}
		onCanceled: root.dragging = false
	}
}
