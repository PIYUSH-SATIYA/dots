#!/bin/bash

set -u

STATE="$HOME/.config/theme-system"

. "$STATE/render.sh"
render_theme || exit 1

IFS= read -r mode <"$STATE/mode" 2>/dev/null || mode=
if [ "$mode" = "dynamic" ]; then
  theme="pywal16"
else
  IFS= read -r theme <"$HOME/.config/nvim/lua/current_theme.txt" 2>/dev/null || theme=
fi

SHELL_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/hypr-shell/mode"
IFS= read -r shell_mode <"$SHELL_STATE" 2>/dev/null || shell_mode=legacy

if [ "$shell_mode" != "quickshell" ]; then
  (
    if pgrep -x waybar >/dev/null; then
      pkill -x waybar || true
      for _ in {1..20}; do
        pgrep -x waybar >/dev/null || break
        sleep 0.05
      done
    fi
    if command -v setsid >/dev/null; then
      setsid -f waybar >/dev/null 2>&1
    else
      nohup waybar >/dev/null 2>&1 &
    fi
  ) &
fi

swaync-client -rs >/dev/null 2>&1 &
pkill -USR1 -x kitty >/dev/null 2>&1 &
pkill -USR2 -x btop >/dev/null 2>&1 &

(
  sleep 0.1
  mkdir -p "$HOME/.cache/theme-system"
  touch "$HOME/.cache/theme-system/opencode-refresh"
) &

hyprctl reload >/dev/null 2>&1 &

if [ -n "$theme" ] && command -v nvim >/dev/null; then
  (
    uid="${UID:-$(id -u)}"
    for server in "/run/user/$uid"/nvim.* /tmp/nvim.*; do
      [ -S "$server" ] || continue
      nvim --server "$server" --remote-expr "execute('colorscheme $theme')" >/dev/null 2>&1 &
    done
  ) &
fi

(
  if [ -f "$STATE/generated/chromium.json" ] && [ -d /etc/chromium/policies/managed ]; then
    if ! cmp -s "$STATE/generated/chromium.json" /etc/chromium/policies/managed/theme.json; then
      cp "$STATE/generated/chromium.json" /etc/chromium/policies/managed/theme.json 2>/dev/null || true
      if pgrep -x chromium >/dev/null; then
        chromium --refresh-platform-policy --no-startup-window >/dev/null 2>&1 &
      fi
    fi
  fi
) &

(
  if command -v gsettings >/dev/null; then
    current=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
    if [ -n "$current" ]; then
      other="Adwaita-dark"
      [ "$current" = "Adwaita-dark" ] && other="Materia-dark"
      gsettings set org.gnome.desktop.interface gtk-theme "$other" 2>/dev/null || true
      gsettings set org.gnome.desktop.interface gtk-theme "$current" 2>/dev/null || true
    fi
  fi
) &

(
  if command -v systemctl >/dev/null 2>&1 &&
    systemctl --user is-active --quiet xdg-desktop-portal-gtk.service 2>/dev/null; then
    systemctl --user restart xdg-desktop-portal-gtk.service >/dev/null 2>&1 || true
  fi
) &

wait
