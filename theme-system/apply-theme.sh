#!/bin/bash

MODE=$(cat "$HOME/.config/theme-system/mode")

if [ "$MODE" = "dynamic" ]; then
  WALL=$(cat "$HOME/.cache/wal/wal")

  wal -i "$WALL" \
    -n \
    --backend colorthief
else
  THEME=$(cat "$HOME/.config/theme-system/current-theme")

  wal -f "$HOME/.config/themes/${THEME}/${THEME}.json"
  NVIM_THEME="$HOME/.config/themes/$THEME/nvim.lua"

  if [ -f "$NVIM_THEME" ]; then
    cp "$NVIM_THEME" \
      "$HOME/.config/nvim/lua/current_theme.lua"
  fi
fi

"$HOME/.config/theme-system/refresh.sh"
