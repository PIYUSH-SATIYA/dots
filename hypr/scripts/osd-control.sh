#!/usr/bin/env bash

set -euo pipefail

mode="$("$HOME/.config/hypr/scripts/shell-mode.sh" status)"
action="${1:-}"
step="${2:-5}"

brightness_legacy() {
	local direction="$1"
	local amount="$2"

	if [ "$direction" = "up" ]; then
		brightnessctl -e set "+${amount}%" >/dev/null
	else
		brightnessctl -e set "${amount}%-" >/dev/null
	fi

	local current
	local maximum
	local progress
	local percent

	current=$(brightnessctl g)
	maximum=$(brightnessctl m)

	if [ "$maximum" -le 0 ]; then
		exit 1
	fi

	progress=$(awk -v current="$current" -v maximum="$maximum" 'BEGIN { printf "%.6f", current / maximum }')
	percent=$((current * 100 / maximum))

	swayosd-client \
		--custom-icon display-brightness-symbolic \
		--custom-progress "$progress" \
		--custom-progress-text "$(printf '%3d%%' "$percent")"
}

if [ "$mode" = "quickshell" ] && pgrep -x quickshell >/dev/null 2>&1; then
	case "$action" in
	volume-up)
		quickshell ipc call osd volumeUp "$step"
		;;
	volume-down)
		quickshell ipc call osd volumeDown "$step"
		;;
	volume-mute)
		quickshell ipc call osd toggleMute
		;;
	brightness-up)
		quickshell ipc call osd brightnessUp "$step"
		;;
	brightness-down)
		quickshell ipc call osd brightnessDown "$step"
		;;
	*)
		printf 'usage: %s [volume-up|volume-down|volume-mute|brightness-up|brightness-down] [step]\n' "$0" >&2
		exit 2
		;;
	esac
else
	case "$action" in
	volume-up)
		swayosd-client --output-volume "+${step}"
		;;
	volume-down)
		swayosd-client --output-volume "-${step}"
		;;
	volume-mute)
		swayosd-client --output-volume mute-toggle
		;;
	brightness-up)
		brightness_legacy up "$step"
		;;
	brightness-down)
		brightness_legacy down "$step"
		;;
	*)
		printf 'usage: %s [volume-up|volume-down|volume-mute|brightness-up|brightness-down] [step]\n' "$0" >&2
		exit 2
		;;
	esac
fi
