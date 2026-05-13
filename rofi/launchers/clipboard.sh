#!/usr/bin/env bash

theme="$HOME/.config/rofi/theme.rasi"

selection=$(
  cliphist list-preview |
    rofi -dmenu -i -p "Clipboard" -theme "$theme"
)

[[ -z "$selection" ]] && exit 0

cliphist decode <<<"$selection" | wl-copy
