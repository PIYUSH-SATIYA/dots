#!/usr/bin/env bash

set -u

direction="${1:-up}"
step="${2:-5}"
min=10
current=$(brightnessctl -m 2>/dev/null | awk -F, '{ gsub(/%/, "", $4); print $4 }')

case "$direction" in
up)
	brightnessctl -e set "+${step}%" >/dev/null 2>&1 || exit 1
	;;
down)
	if [ "${current:-0}" -gt "$min" ]; then
		brightnessctl -e set "${step}%-" >/dev/null 2>&1 || exit 1
	fi
	;;
set)
	if [ "$step" -lt "$min" ]; then
		step="$min"
	elif [ "$step" -gt 100 ]; then
		step=100
	fi
	brightnessctl set "${step}%" >/dev/null 2>&1 || exit 1
	;;
*)
	exit 2
	;;
esac

percent=$(brightnessctl -m | awk -F, '{ gsub(/%/, "", $4); print $4 }')

if [ -z "$percent" ]; then
	exit 1
fi

if [ "$percent" -lt "$min" ]; then
	brightnessctl set "${min}%" >/dev/null 2>&1 || exit 1
	percent="$min"
fi

printf '%s\n' "$percent"
