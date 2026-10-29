#!/usr/bin/env bash

set -euo pipefail

MODE="$("$HOME/.config/hypr/scripts/shell-mode.sh" status)"
ACTION="${1:-toggle}"

quickshell_running() {
	pgrep -x quickshell >/dev/null 2>&1
}

if [ "$MODE" = "quickshell" ] && quickshell_running; then
	case "$ACTION" in
	toggle) quickshell ipc call notifications toggleCenter ;;
	close-latest) quickshell ipc call notifications closeLatest ;;
	clear-all) quickshell ipc call notifications clearAll ;;
	dnd) quickshell ipc call notifications toggleDnd ;;
	*)
		printf 'usage: %s [toggle|close-latest|clear-all|dnd]\n' "$0" >&2
		exit 2
		;;
	esac
	exit 0
fi

case "$ACTION" in
toggle) swaync-client -t ;;
close-latest) swaync-client --close-latest ;;
clear-all) swaync-client -C && notify-send "Notifications cleared" ;;
dnd) swaync-client -d ;;
*)
	printf 'usage: %s [toggle|close-latest|clear-all|dnd]\n' "$0" >&2
	exit 2
	;;
esac
