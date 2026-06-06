#!/bin/bash

THEME="$1"

THEME_PATH="$HOME/.config/themes/${THEME}/${THEME}.json"

if [ ! -f "$THEME_PATH" ]; then
  notify-send "Theme not found"
  exit 1
fi

echo "static" >"$HOME/.config/theme-system/mode"

echo "$THEME" >"$HOME/.config/theme-system/current-theme"

"$HOME/.config/theme-system/apply-theme.sh"
