#!/bin/bash

set -e

THEME="$1"

HOME_DIR="$HOME"

THEME_PATH="$HOME_DIR/.config/themes/${THEME}/${THEME}.json"

if [ ! -f "$THEME_PATH" ]; then
  notify-send "Theme not found"
  exit 1
fi

echo "static" \
  >"$HOME_DIR/.config/theme-system/mode"

echo "$THEME" \
  >"$HOME_DIR/.config/theme-system/current-theme"

"$HOME_DIR/.config/theme-system/apply-theme.sh"

# RANDOM WALLPAPER FROM THEME DIRECTORY

WALLPAPER_DIR="$HOME_DIR/Pictures/wallpapers/$THEME"

FULL_PATH=$(
  find "$WALLPAPER_DIR" -type f \
    \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.webp" \
    \) | shuf -n 1
)

if [ -n "$FULL_PATH" ]; then
  "$HOME_DIR/.config/theme-system/set-wallpaper.sh" \
    "$FULL_PATH"
fi
