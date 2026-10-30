#!/usr/bin/env bash

set -u

read -r load1 _ </proc/loadavg

mem_total_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
mem_available_kb=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
mem_used_kb=$((mem_total_kb - mem_available_kb))
mem_used=$(awk -v kb="$mem_used_kb" 'BEGIN { printf "%.1f", kb / 1048576 }')
mem_total=$(awk -v kb="$mem_total_kb" 'BEGIN { printf "%.1f", kb / 1048576 }')
mem_pct=$((mem_used_kb * 100 / mem_total_kb))

mapfile -t cpu1 < <(grep '^cpu[0-9]' /proc/stat)
sleep 0.25
mapfile -t cpu2 < <(grep '^cpu[0-9]' /proc/stat)

blocks=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
cores=""
cpu_used=0
cpu_total=0

for i in "${!cpu1[@]}"; do
	read -r _ u1 n1 sy1 id1 io1 irq1 sirq1 _ <<<"${cpu1[$i]}"
	read -r _ u2 n2 sy2 id2 io2 irq2 sirq2 _ <<<"${cpu2[$i]}"

	idle1=$((id1 + io1))
	idle2=$((id2 + io2))
	total1=$((u1 + n1 + sy1 + id1 + io1 + irq1 + sirq1))
	total2=$((u2 + n2 + sy2 + id2 + io2 + irq2 + sirq2))
	delta=$((total2 - total1))
	idle=$((idle2 - idle1))

	if [ "$delta" -gt 0 ]; then
		used=$((delta - idle))
		usage=$((used * 100 / delta))
	else
		used=0
		usage=0
	fi

	idx=$((usage * 7 / 100))
	[ "$idx" -gt 7 ] && idx=7
	[ "$idx" -lt 0 ] && idx=0

	cores+="${blocks[$idx]}"
	cpu_used=$((cpu_used + used))
	cpu_total=$((cpu_total + delta))
done

if [ "$cpu_total" -gt 0 ]; then
	cpu=$((cpu_used * 100 / cpu_total))
else
	cpu=0
fi

temp=0
if [ -r /sys/class/thermal/thermal_zone9/temp ]; then
	read -r temp_raw </sys/class/thermal/thermal_zone9/temp
	temp=$((temp_raw / 1000))
fi

brightness=0
if command -v brightnessctl >/dev/null 2>&1; then
	brightness_raw=$(brightnessctl -m 2>/dev/null || true)
	if [ -n "$brightness_raw" ]; then
		IFS=, read -r _ _ current _ maximum <<<"$brightness_raw"
		if [ -n "${current:-}" ] && [ -n "${maximum:-}" ] && [ "$maximum" -gt 0 ]; then
			brightness=$((current * 100 / maximum))
		fi
	fi
fi

volume=0
muted=0

if command -v wpctl >/dev/null 2>&1; then
	audio_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)
	if [ -n "$audio_raw" ]; then
		volume=$(awk '{ printf "%d", $2 * 100 }' <<<"$audio_raw")
		case "$audio_raw" in
		*MUTED*) muted=1 ;;
		esac
	fi
fi

wifi_state=disconnected
wifi_ssid=""
wifi_signal=0

if command -v iwctl >/dev/null 2>&1; then
	wifi_raw=$(iwctl station wlan0 show 2>/dev/null | sed -r 's/\x1B\[[0-9;]*[mK]//g' || true)
	if [ -n "$wifi_raw" ]; then
		wifi_state=$(awk '/^ *State / {print $2; exit}' <<<"$wifi_raw")
		wifi_ssid=$(awk '/Connected network/ {print $3; exit}' <<<"$wifi_raw")
		wifi_rssi=$(awk '/^ *RSSI / {print $2; exit}' <<<"$wifi_raw")
	fi
fi

if [ "$wifi_state" = "connected" ] && [ -r /proc/net/wireless ]; then
	wifi_signal=$(awk 'NR==3 {gsub(/\./, "", $3); print $3}' /proc/net/wireless)
fi

jq -cn \
	--argjson cpu "$cpu" \
	--arg cores "$cores" \
	--argjson mem_used "$mem_used" \
	--argjson mem_total "$mem_total" \
	--argjson mem_pct "$mem_pct" \
	--argjson temp "$temp" \
	--arg load "$load1" \
	--arg wifi_state "$wifi_state" \
	--arg wifi_ssid "$wifi_ssid" \
	--argjson wifi_signal "${wifi_signal:-0}" \
	--argjson brightness "$brightness" \
	--argjson volume "$volume" \
	--argjson muted "$muted" \
	'{
		cpu: $cpu,
		cores: $cores,
		mem_used: $mem_used,
		mem_total: $mem_total,
		mem_pct: $mem_pct,
		temp: $temp,
		load: $load,
		wifi_state: $wifi_state,
		wifi_ssid: $wifi_ssid,
		wifi_signal: $wifi_signal,
		brightness: $brightness,
		volume: $volume,
		muted: $muted
	}'
