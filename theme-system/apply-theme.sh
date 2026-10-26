#!/bin/bash

set -e

STATE="$HOME/.config/theme-system"
MODE=$(cat "$STATE/mode")
CURRENT_WALLPAPER=$(cat "$STATE/current-wallpaper")

if [ "$MODE" = "dynamic" ]; then
  wal -i "$CURRENT_WALLPAPER" -n --backend colorthief
else
  THEME=$(cat "$STATE/current-theme")
  wal -f "$HOME/.config/themes/${THEME}/${THEME}.json"

  NVIM_THEME="$HOME/.config/themes/$THEME/nvim.txt"
  if [ -f "$NVIM_THEME" ]; then
    cp "$NVIM_THEME" "$HOME/.config/nvim/lua/current_theme.txt"
  fi
fi

"$STATE/refresh.sh"
