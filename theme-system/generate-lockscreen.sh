#!/bin/bash

FULL_PATH="$1"

LOCK_WALL="$HOME/.cache/lockscreen.png"

TMP_LOCK="${LOCK_WALL}.tmp"

magick "$FULL_PATH" \
  -resize 1920x1080^ \
  -gravity center \
  -extent 1920x1080 \
  \
  -fill black -colorize 55% \
  "$TMP_LOCK" # -gaussian-blur 0x2 \

mv "$TMP_LOCK" "$LOCK_WALL"
