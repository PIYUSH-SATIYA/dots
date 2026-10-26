#!/bin/bash

set -u

render_theme() {
  local home="$HOME"
  local wal="$home/.cache/wal/colors.sh"
  local out="$home/.config/theme-system/generated"

  if [ ! -f "$wal" ]; then
    printf 'theme-system: missing %s\n' "$wal" >&2
    return 1
  fi

  local key value
  local -A c=()
  while IFS='=' read -r key value; do
    case "$key" in
      background | foreground | cursor | color[0-9] | color1[0-5])
        value=${value#\'}
        value=${value%\'}
        value=${value#\"}
        value=${value%\"}
        c[$key]=$value
        ;;
    esac
  done <"$wal"

  normalize() {
    HEX=${1#\#}
    HEX=${HEX,,}
    if [ "${#HEX}" -eq 3 ]; then
      HEX="${HEX:0:1}${HEX:0:1}${HEX:1:1}${HEX:1:1}${HEX:2:1}${HEX:2:1}"
    fi
  }

  blend() {
    local a="$1" b="$2" percent="${3:-60}"
    local ar=$((16#${a:0:2})) ag=$((16#${a:2:2})) ab=$((16#${a:4:2}))
    local br=$((16#${b:0:2})) bg=$((16#${b:2:2})) bb=$((16#${b:4:2}))
    printf -v BLEND '%02x%02x%02x' \
      $(((ar * percent + br * (100 - percent)) / 100)) \
      $(((ag * percent + bg * (100 - percent)) / 100)) \
      $(((ab * percent + bb * (100 - percent)) / 100))
  }

  local bg fg cursor
  normalize "${c[background]:-${c[color0]:-}}"
  bg=$HEX
  normalize "${c[foreground]:-${c[color15]:-}}"
  fg=$HEX
  normalize "${c[cursor]:-$fg}"
  cursor=$HEX

  local -a cols=()
  local i
  for i in {0..15}; do
    normalize "${c[color$i]:-$fg}"
    cols[$i]=$HEX
  done

  local accent="${cols[4]}"
  local tmp="$out/.render.$$"
  mkdir -p "$out" "$tmp" || return 1

  {
    printf '@define-color foreground #%s;\n' "$fg"
    printf '@define-color background #%s;\n' "$bg"
    printf '@define-color cursor #%s;\n' "$cursor"
    for i in {0..15}; do
      printf '@define-color color%d #%s;\n' "$i" "${cols[$i]}"
    done
    printf '@define-color theme_fg_color #%s;\n' "$fg"
    printf '@define-color theme_text_color #%s;\n' "$fg"
    printf '@define-color theme_bg_color #%s;\n' "$bg"
    printf '@define-color theme_base_color #%s;\n' "$bg"
    printf '@define-color theme_selected_bg_color #%s;\n' "$accent"
    printf '@define-color theme_selected_fg_color #%s;\n' "$bg"
    printf '@define-color insensitive_fg_color #%s;\n' "${cols[8]}"
    printf '@define-color borders #%s;\n' "${cols[8]}"
    printf '@define-color warning_color #%s;\n' "${cols[3]}"
    printf '@define-color error_color #%s;\n' "${cols[1]}"
    printf '@define-color success_color #%s;\n' "${cols[2]}"
  } >"$tmp/colors-gtk.css"

  printf 'return {\n\tactive = "rgba(%sff)",\n\tactive_alt = "rgba(%sff)",\n\tinactive = "rgba(%saa)",\n}\n' \
    "$bg" "$accent" "${cols[8]}" >"$tmp/hyprland.lua"

  {
    printf '$background = rgba(%sff)\n' "$bg"
    printf '$foreground = rgba(%sff)\n' "$fg"
    printf '$cursor = rgba(%sff)\n' "$cursor"
    for i in {0..15}; do
      printf '$color%d = rgba(%sff)\n' "$i" "${cols[$i]}"
    done
  } >"$tmp/hyprlock.conf"

  {
    printf 'theme[main_bg]="#%s"\n' "$bg"
    printf 'theme[main_fg]="#%s"\n' "$fg"
    printf 'theme[title]="#%s"\n' "$accent"
    printf 'theme[hi_fg]="#%s"\n' "${cols[4]}"
    printf 'theme[selected_bg]="#%s"\n' "${cols[0]}"
    printf 'theme[selected_fg]="#%s"\n' "$fg"
    printf 'theme[inactive_fg]="#%s"\n' "${cols[8]}"
    printf 'theme[graph_text]="#%s"\n' "$fg"
    printf 'theme[proc_misc]="#%s"\n' "${cols[6]}"
    printf 'theme[cpu_box]="#%s"\n' "${cols[8]}"
    printf 'theme[mem_box]="#%s"\n' "${cols[8]}"
    printf 'theme[net_box]="#%s"\n' "${cols[8]}"
    printf 'theme[proc_box]="#%s"\n' "${cols[8]}"
    printf 'theme[div_line]="#%s"\n' "${cols[8]}"
    printf 'theme[temp_start]="#%s"\n' "${cols[2]}"
    printf 'theme[temp_mid]="#%s"\n' "${cols[3]}"
    printf 'theme[temp_end]="#%s"\n' "${cols[1]}"
    printf 'theme[cpu_start]="#%s"\n' "${cols[2]}"
    printf 'theme[cpu_mid]="#%s"\n' "${cols[3]}"
    printf 'theme[cpu_end]="#%s"\n' "${cols[1]}"
    printf 'theme[free_start]="#%s"\n' "${cols[1]}"
    printf 'theme[free_mid]="#%s"\n' "${cols[3]}"
    printf 'theme[free_end]="#%s"\n' "${cols[2]}"
    printf 'theme[cached_start]="#%s"\n' "${cols[4]}"
    printf 'theme[cached_mid]="#%s"\n' "${cols[6]}"
    printf 'theme[cached_end]="#%s"\n' "${cols[2]}"
    printf 'theme[available_start]="#%s"\n' "${cols[1]}"
    printf 'theme[available_mid]="#%s"\n' "${cols[3]}"
    printf 'theme[available_end]="#%s"\n' "${cols[2]}"
    printf 'theme[used_start]="#%s"\n' "${cols[2]}"
    printf 'theme[used_mid]="#%s"\n' "${cols[3]}"
    printf 'theme[used_end]="#%s"\n' "${cols[1]}"
    printf 'theme[download_start]="#%s"\n' "${cols[2]}"
    printf 'theme[download_mid]="#%s"\n' "${cols[6]}"
    printf 'theme[download_end]="#%s"\n' "${cols[4]}"
    printf 'theme[upload_start]="#%s"\n' "${cols[3]}"
    printf 'theme[upload_mid]="#%s"\n' "${cols[1]}"
    printf 'theme[upload_end]="#%s"\n' "${cols[5]}"
    printf 'theme[process_start]="#%s"\n' "${cols[2]}"
    printf 'theme[process_mid]="#%s"\n' "${cols[5]}"
    printf 'theme[process_end]="#%s"\n' "${cols[1]}"
  } >"$tmp/btop.theme"

  blend "$bg" "${cols[8]}" 60
  printf '{\n  "BrowserThemeColor": "#%s",\n  "BrowserColorScheme": "dark"\n}\n' \
    "$BLEND" >"$tmp/chromium.json"

  mv -f "$tmp"/* "$out"/ || return 1
  rmdir "$tmp" 2>/dev/null || true
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -e
  render_theme
fi
