pragma Singleton

import QtQuick
import Quickshell

Singleton {
	id: root

	property bool open: false
	property string mode: "apps"
	property string query: ""

	function show(mode) {
		root.mode = mode || "apps"
		root.query = ""
		root.open = true
	}

	function toggle() {
		if (root.open) {
			root.open = false
			return
		}

		root.show("apps")
	}

	function close() {
		root.open = false
		root.query = ""
	}

	function setQuery(value) {
		root.query = value
	}
}
