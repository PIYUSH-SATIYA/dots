#!/usr/bin/env bash
# Per-core CPU usage as a compact unicode-block sparkline for waybar.
# Outputs JSON {"text": "...", "tooltip": "..."} on stdout.

set -euo pipefail

read_stat() {
    grep '^cpu[0-9]' /proc/stat
}

mapfile -t s1 < <(read_stat)
sleep 0.4
mapfile -t s2 < <(read_stat)

blocks=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
out=""
tooltip="per-core usage"

for i in "${!s1[@]}"; do
    read -r _ u1 n1 sy1 id1 io1 irq1 sirq1 _ <<< "${s1[$i]}"
    read -r _ u2 n2 sy2 id2 io2 irq2 sirq2 _ <<< "${s2[$i]}"

    idle1=$((id1 + io1))
    idle2=$((id2 + io2))
    total1=$((u1 + n1 + sy1 + id1 + io1 + irq1 + sirq1))
    total2=$((u2 + n2 + sy2 + id2 + io2 + irq2 + sirq2))

    dtotal=$((total2 - total1))
    didle=$((idle2 - idle1))

    if [ "$dtotal" -gt 0 ]; then
        usage=$(( (100 * (dtotal - didle)) / dtotal ))
    else
        usage=0
    fi

    idx=$(( usage * 7 / 100 ))
    [ "$idx" -gt 7 ] && idx=7

    out+="${blocks[$idx]}"
    tooltip+="\ncore ${i}: ${usage}%"
done

printf '{"text": "%s", "tooltip": "%s"}\n' "$out" "$tooltip"
