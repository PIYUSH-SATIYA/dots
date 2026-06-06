#!/bin/bash

FULL_PATH="$1"

LOCK_WALL="$HOME/.cache/lockscreen.png"

TMP_LOCK="${LOCK_WALL}.tmp"

magick "$FULL_PATH" \
  -resize 1920x1080^ \
  -gravity center \
  -extent 1920x1080 \
  -gaussian-blur 0x4 \
  -fill black -colorize 35% \
  "$TMP_LOCK"

mv "$TMP_LOCK" "$LOCK_WALL"
