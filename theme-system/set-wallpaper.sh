#!/bin/bash

set -e

HOME_DIR="$HOME"

MODE_FILE="$HOME_DIR/.config/theme-system/mode"

CURRENT_WALLPAPER_FILE="$HOME_DIR/.config/theme-system/current-wallpaper"

WALLPAPER_DIR="$HOME_DIR/Pictures/wallpapers"

FULL_PATH="${1:-$(find "$WALLPAPER_DIR" -type f | shuf -n 1)}"

echo "$FULL_PATH" >"$CURRENT_WALLPAPER_FILE"

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

"$HOME_DIR/.config/theme-system/apply-theme.sh"

"$HOME_DIR/.config/theme-system/generate-lockscreen.sh" "$FULL_PATH"
