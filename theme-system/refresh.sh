#!/bin/bash

set -u

STATE="$HOME/.config/theme-system"

"$STATE/render.py" || exit 1

if pgrep -x waybar >/dev/null; then
  pkill -x waybar || true
  for _ in $(seq 1 20); do
    pgrep -x waybar >/dev/null || break
    sleep 0.05
  done
fi
if command -v setsid >/dev/null; then
  setsid -f waybar >/dev/null 2>&1
else
  nohup waybar >/dev/null 2>&1 &
fi

swaync-client -rs >/dev/null 2>&1 || true
pkill -USR1 -x kitty >/dev/null 2>&1 || true
pkill -USR2 -x btop >/dev/null 2>&1 || true
pkill -USR2 -x opencode >/dev/null 2>&1 || true

if command -v nvr >/dev/null; then
  mode=$(cat "$STATE/mode" 2>/dev/null || true)
  if [ "$mode" = "dynamic" ]; then
    theme="pywal16"
  else
    theme=$(cat "$HOME/.config/nvim/lua/current_theme.txt" 2>/dev/null || true)
  fi
  if [ -n "$theme" ]; then
    while IFS= read -r server; do
      [ -n "$server" ] || continue
      nvr --servername "$server" --remote-expr "execute('colorscheme $theme')" >/dev/null 2>&1 || true
    done < <(nvr --serverlist 2>/dev/null)
  fi
fi

hyprctl reload >/dev/null 2>&1 || true

if [ -f "$STATE/generated/chromium.json" ] && [ -d /etc/chromium/policies/managed ]; then
  cp "$STATE/generated/chromium.json" /etc/chromium/policies/managed/theme.json 2>/dev/null || true
  if pgrep -x chromium >/dev/null; then
    chromium --refresh-platform-policy --no-startup-window >/dev/null 2>&1 &
  fi
fi

if command -v gsettings >/dev/null; then
  current=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
  if [ -n "$current" ]; then
    other="Adwaita-dark"
    [ "$current" = "Adwaita-dark" ] && other="Materia-dark"
    gsettings set org.gnome.desktop.interface gtk-theme "$other" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme "$current" 2>/dev/null || true
  fi
fi
