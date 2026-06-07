#!/bin/bash

set -e

DIR="$HOME/Pictures/wallpapers"

FULL_PATH="${1:-$(find "$DIR" -type f | shuf -n 1)}"

TRANSITIONS=(
  "grow"
  "outer"
  "wipe"
  "wave"
  "center"
  "random"
)

TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}

awww img "$FULL_PATH" \
  --transition-type "$TRANSITION" \
  --transition-fps 60 \
  --transition-duration 1.2 \
  --transition-step 90

MODE=$(cat "$HOME/.config/theme-system/mode")

if [ "$MODE" = "dynamic" ]; then
  wal -i "$FULL_PATH" \
    -n \
    --backend colorthief

  "$HOME/.config/theme-system/refresh.sh"
fi

"$HOME/.config/theme-system/generate-lockscreen.sh" "$FULL_PATH"
