pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
	id: root

	property var server: null
	property bool centerOpen: false
	property bool dnd: false
	property var toasts: []

	readonly property var tracked: root.server ? root.server.trackedNotifications.values : []
	readonly property int count: root.tracked.length

	function toggleCenter() {
		root.centerOpen = !root.centerOpen
	}

	function toggleDnd() {
		root.dnd = !root.dnd
		if (root.dnd)
			root.toasts = []
	}

	function register(notification) {
		if (!notification)
			return

		notification.tracked = true
		if (notification.lastGeneration || root.dnd)
			return

		const next = root.toasts.slice()
		next.unshift(notification)
		root.toasts = next.slice(0, 5)
	}

	function removeToast(notification) {
		root.toasts = root.toasts.filter(item => item !== notification)
	}

	function clearAll() {
		const items = root.tracked.slice()
		for (const notification of items)
			notification.dismiss()
	}

	function closeLatest() {
		const items = root.tracked.slice()
		if (items.length > 0)
			items[items.length - 1].dismiss()
	}

	function invokeDefault(notification) {
		if (!notification)
			return

		for (const action of notification.actions) {
			if (action.identifier === "default") {
				action.invoke()
				return
			}
		}

		notification.dismiss()
	}

	function toastTimeout(notification) {
		if (!notification)
			return 0
		if (notification.expireTimeout > 0)
			return notification.expireTimeout
		if (notification.expireTimeout === 0)
			return 0
		if (notification.urgency === NotificationUrgency.Critical)
			return 0
		if (notification.urgency === NotificationUrgency.Low)
			return 5000
		return 10000
	}
}
