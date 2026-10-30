#!/usr/bin/env bash

set -u

action="${1:-get}"
step="${2:-5}"

case "$action" in
up)
	wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 >/dev/null 2>&1 || exit 1
	wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "${step}%+" >/dev/null 2>&1 || exit 1
	;;
down)
	wpctl set-volume @DEFAULT_AUDIO_SINK@ "${step}%-" >/dev/null 2>&1 || exit 1
	;;
mute)
	wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle >/dev/null 2>&1 || exit 1
	;;
set)
	wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "${step}%" >/dev/null 2>&1 || exit 1
	;;
get) ;;
*)
	exit 2
	;;
esac

state=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || exit 1
volume=$(awk '{ printf "%d", $2 * 100 }' <<<"$state")
muted=0

case "$state" in
*MUTED*) muted=1 ;;
esac

printf '%s:%s\n' "$volume" "$muted"
