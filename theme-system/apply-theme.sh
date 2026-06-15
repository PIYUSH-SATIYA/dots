#!/bin/bash

set -e

HOME_DIR="$HOME"

MODE=$(cat "$HOME_DIR/.config/theme-system/mode")

CURRENT_WALLPAPER=$(cat "$HOME_DIR/.config/theme-system/current-wallpaper")

if [ "$MODE" = "dynamic" ]; then

  wal -i "$CURRENT_WALLPAPER" \
    -n \
    --backend colorthief

else

  THEME=$(cat "$HOME_DIR/.config/theme-system/current-theme")

  wal -f "$HOME_DIR/.config/themes/${THEME}/${THEME}.json"

  NVIM_THEME="$HOME_DIR/.config/themes/$THEME/nvim.txt"

  if [ -f "$NVIM_THEME" ]; then
    cp "$NVIM_THEME" \
      "$HOME_DIR/.config/nvim/lua/current_theme.txt"
  fi

fi

"$HOME_DIR/.config/theme-system/refresh.sh"
