#!/bin/bash

echo "dynamic" >"$HOME/.config/theme-system/mode"

FULL_PATH=$(cat ~/.cache/wal/wal)

~/.config/hypr/scripts/wallpaper.sh "$FULL_PATH"
