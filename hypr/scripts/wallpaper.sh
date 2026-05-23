#!/bin/bash

set -e

DIR="$HOME/Pictures/wallpapers"
FULL_PATH="${1:-$(find "$DIR" -type f | shuf -n 1)}"

LOCK_WALL="$HOME/.cache/lockscreen.png"

# Set wallpaper
# awww img "$FULL_PATH" \
#   --transition-type outer \
#   --transition-step 90

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

# Generate pywal colors
# wal -i "$FULL_PATH" -n --backend colorthief
wal -i "$FULL_PATH" -n --backend colorthief

# Apply pywal color to Chromium
source "$HOME/.cache/wal/colors.sh"

hex_to_rgb() {
  hex="${1#"#"}"
  printf "%d %d %d\n" \
    "0x${hex:0:2}" \
    "0x${hex:2:2}" \
    "0x${hex:4:2}"
}

rgb_to_hex() {
  printf "#%02x%02x%02x\n" "$1" "$2" "$3"
}

blend_colors() {
  read r1 g1 b1 <<<"$(hex_to_rgb "$1")"
  read r2 g2 b2 <<<"$(hex_to_rgb "$2")"

  r=$(((r1 * 60 + r2 * 40) / 100))
  g=$(((g1 * 60 + g2 * 40) / 100))
  b=$(((b1 * 60 + b2 * 40) / 100))

  rgb_to_hex "$r" "$g" "$b"
}

# Blend background with muted accent
CHROMIUM_COLOR=$(blend_colors "$background" "$color2")

mkdir -p /etc/chromium/policies/managed

cat <<EOF >/etc/chromium/policies/managed/theme.json
{
  "BrowserThemeColor": "$CHROMIUM_COLOR",
  "BrowserColorScheme": "dark"
}
EOF

if pgrep -x chromium >/dev/null; then
  chromium --refresh-platform-policy --no-startup-window >/dev/null 2>&1 &
fi

### adding for more readability and contrast by opencode
# Override pywal special colors for readability
# ~/.config/wal/override-special.py
# Override pywal special colors for readability (fast path, requires jq)
# wal_json="$HOME/.cache/wal/colors.json"
# tmp_json="${wal_json}.tmp"
# jq \
#   --arg bg "#101317" \
#   --arg fg "#e6e6e6" \
#   '(.special.background) = $bg
#    | (.special.foreground) = $fg
#    | (.special.cursor) = $fg' \
#   "$wal_json" >"$tmp_json" && mv "$tmp_json" "$wal_json"

# Generate blurred lockscreen
(
  TMP_LOCK="${LOCK_WALL}.tmp"

  magick "$FULL_PATH" \
    -resize 1920x1080^ \
    -gravity center \
    -extent 1920x1080 \
    -blur 0x16 \
    -brightness-contrast -20x-25 \
    "$TMP_LOCK"

  mv "$TMP_LOCK" "$LOCK_WALL"
) &

# Reload waybar
killall waybar || true

while pgrep -u "$USER" -x waybar >/dev/null; do
  sleep 0.2
done

waybar >/dev/null 2>&1 &

# Reload swaync
swaync-client -rs || true

# Reload Neovim themes
#if command -v nvr >/dev/null; then
#  nvr --serverlist | while read -r server; do
#    nvr --servername "$server" \
#      -c "doautocmd User ThemeReload"
#  done
#fi

##!/bin/bash
#
#DIR="$HOME/Pictures/wallpapers"
#
#PICS=($(ls "$DIR"))
#
## RANDOM_PIC=${PICS[$RANDOM % ${#PICS[@]}]}
#
## FULL_PATH="$DIR/$RANDOM_PIC"
#FULL_PATH="${1:-$(find "$DIR" -type f | shuf -n 1)}"
#
#LOCK_WALL="$HOME/.cache/lockscreen.png"
#
## Set wallpaper
#awww img "$FULL_PATH" \
#  --transition-type outer \
#  --transition-step 90
#
## Kill previous blur generation
#pkill -f "magick.*lockscreen.png" || true
#
## Generate blurred wallpaper in background
#(
#  TMP_LOCK="${LOCK_WALL}.tmp"
#
#  magick "$FULL_PATH" \
#    -resize 1920x1080^ \
#    -gravity center \
#    -extent 1920x1080 \
#    -blur 0x16 \
#    -brightness-contrast -20x-25 \
#    "$TMP_LOCK"
#
#  mv "$TMP_LOCK" "$LOCK_WALL"
#) &
#
## Generate colors
#wal -i "$FULL_PATH" -n --backend colorthief
#
## Restart Waybar
#killall waybar
#
#while pgrep -u $USER -x waybar >/dev/null; do
#  sleep 1
#done
#
#waybar &
#
## Generate colors for everything including nvim templates
#wal -i "$FULL_PATH" -n --backend colorthief
#
## Reload Neovim themes
#nvr --serverlist | xargs -I {} \
#  nvr --servername {} \
#  -c "doautocmd User ThemeReload"
#
## reloading swaync theme
#swaync-client -R
#swaync-client -rs
#swaync-client -t
#pkill swaync &
#>/dev/null
#swaync &
#>/dev/null
#swaync-client -t

##!/bin/bash
#DIR=$HOME/Pictures/wallpapers
#PICS=($(ls $DIR))
#RANDOM_PIC=${PICS[$RANDOM % ${#PICS[@]}]}
#FULL_PATH="$DIR/$RANDOM_PIC"
#
## 1. Set Wallpaper
#awww img "$FULL_PATH" --transition-type "outer" --transition-step 90
#
## 2. Generate Colors
## wal -i "$FULL_PATH" -n --backend haishoku
#wal -i "$FULL_PATH" -n --backend colorthief
#
## 3. Robust Waybar Restart
## We kill it, wait a tiny bit, and start it again in the background
#killall waybar
#while pgrep -u $USER -x waybar >/dev/null; do sleep 1; done
#waybar &
#
## Generate colors for everything, including nvim templates
#wal -i "$FULL_PATH" -n --backend haishoku
## Tell all running Neovim instances to trigger the "ThemeReload" event
## This is what talks to the plugin code above
#nvr --serverlist | xargs -I {} nvr --servername {} -c "doautocmd User ThemeReload"
