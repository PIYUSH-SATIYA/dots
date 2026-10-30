#!/usr/bin/env bash

set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypr-shell"
STATE_FILE="$STATE_DIR/mode"
DEFAULT_MODE=legacy

get_mode() {
	local mode="$DEFAULT_MODE"

	if [ -r "$STATE_FILE" ]; then
		IFS= read -r mode <"$STATE_FILE" || mode="$DEFAULT_MODE"
	fi

	case "$mode" in
	legacy | quickshell) printf '%s\n' "$mode" ;;
	*) printf '%s\n' "$DEFAULT_MODE" ;;
	esac
}

set_mode() {
	mkdir -p "$STATE_DIR"
	printf '%s\n' "$1" >"$STATE_FILE"
}

is_running() {
	pgrep -x "$1" >/dev/null 2>&1
}

stop() {
	if is_running "$1"; then
		pkill -x "$1" >/dev/null 2>&1 || true
		for _ in {1..20}; do
			is_running "$1" || return 0
			sleep 0.05
		done
	fi
	return 0
}

launch() {
	if command -v setsid >/dev/null 2>&1; then
		setsid -f "$@" >/dev/null 2>&1
	else
		nohup "$@" >/dev/null 2>&1 &
	fi
}

notify() {
	if command -v notify-send >/dev/null 2>&1; then
		notify-send "$@" >/dev/null 2>&1 || true
	fi
}

start_waybar() {
	is_running waybar || launch waybar
}

start_swayosd() {
	is_running swayosd-server || launch swayosd-server
}

stop_swayosd() {
	stop swayosd-server
}

swaync_service_exists() {
	command -v systemctl >/dev/null 2>&1 &&
		systemctl --user cat swaync.service >/dev/null 2>&1
}

stop_swaync() {
	if swaync_service_exists; then
		systemctl --user stop swaync.service >/dev/null 2>&1 || true
	fi
	stop swaync
}

start_swaync() {
	if swaync_service_exists; then
		systemctl --user unmask swaync.service >/dev/null 2>&1 || true
		systemctl --user start swaync.service >/dev/null 2>&1 || true
	fi
	is_running swaync || launch swaync
}

mask_swaync() {
	if swaync_service_exists; then
		systemctl --user mask swaync.service >/dev/null 2>&1 || true
	fi
}

start_quickshell() {
	if ! command -v quickshell >/dev/null 2>&1; then
		set_mode legacy
		notify "Quickshell is not installed" "Falling back to Waybar"
		start_swaync
		start_swayosd
		start_waybar
		return 0
	fi

	if is_running quickshell; then
		return 0
	fi

	launch quickshell
	for _ in {1..30}; do
		if is_running quickshell; then
			return 0
		fi
		sleep 0.1
	done

	set_mode legacy
	notify "Quickshell failed to start" "Falling back to Waybar"
	start_swaync
	start_swayosd
	start_waybar
}

apply_mode() {
	case "$1" in
	quickshell)
		stop waybar
		stop_swaync
		stop_swayosd
		mask_swaync
		start_quickshell
		;;
	legacy)
		stop quickshell
		start_swaync
		start_swayosd
		start_waybar
		;;
	esac
}

action="${1:-status}"

case "$action" in
status)
	get_mode
	;;
start)
	apply_mode "$(get_mode)"
	;;
legacy | quickshell)
	if [ "$action" = "quickshell" ] && ! command -v quickshell >/dev/null 2>&1; then
		notify "Quickshell is not installed" "Install it before switching"
		exit 1
	fi

	set_mode "$action"
	apply_mode "$action"
	notify "Shell mode" "Using $action"
	;;
toggle)
	current="$(get_mode)"
	if [ "$current" = "quickshell" ]; then
		target=legacy
	else
		target=quickshell
	fi

	if [ "$target" = "quickshell" ] && ! command -v quickshell >/dev/null 2>&1; then
		notify "Quickshell is not installed" "Install it before switching"
		exit 1
	fi

	set_mode "$target"
	apply_mode "$target"
	notify "Shell mode" "Using $target"
	;;
restart)
	mode="$(get_mode)"
	case "$mode" in
	quickshell) stop quickshell ;;
	legacy)
		stop waybar
		stop_swaync
		stop_swayosd
		;;
	esac
	apply_mode "$mode"
	notify "Shell mode" "Restarted $mode"
	;;
*)
	printf 'usage: %s [status|start|legacy|quickshell|toggle|restart]\n' "$0" >&2
	exit 2
	;;
esac
