#!/bin/bash

# Reload Waybar
pkill waybar || true

while pgrep -u "$USER" -x waybar >/dev/null; do
  sleep 0.1
done

waybar >/dev/null 2>&1 &

# Reload Neovim
if command -v nvr >/dev/null; then
  nvr --serverlist | while read -r server; do
    nvr --servername "$server" \
      -c "doautocmd User ThemeReload"
  done
fi

# Reload swaync
swaync-client -rs || true

# Chromium theme
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

CHROMIUM_COLOR=$(blend_colors "$background" "$color8")

mkdir -p /etc/chromium/policies/managed

cat <<EOF >/etc/chromium/policies/managed/theme.json
{
  "BrowserThemeColor": "$CHROMIUM_COLOR",
  "BrowserColorScheme": "dark"
}
EOF

if pgrep -x chromium >/dev/null; then
  chromium --refresh-platform-policy \
    --no-startup-window >/dev/null 2>&1 &
fi
