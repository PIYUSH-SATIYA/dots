#!/usr/bin/env bash

set -u

mode="${1:-toggle}"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hypr-shell"
state_file="$state_dir/mode"
shell_mode="legacy"

if [ -r "$state_file" ]; then
	IFS= read -r shell_mode <"$state_file" || shell_mode=legacy
fi

if [ "$shell_mode" = "quickshell" ] && command -v qs >/dev/null 2>&1; then
	case "$mode" in
	toggle)
		qs ipc call launcher toggle && exit 0
		;;
	*)
		qs ipc call launcher open "$mode" && exit 0
		;;
	esac
fi

case "$mode" in
toggle | apps)
	walker -t pywal
	;;
files)
	walker -t pywal --provider files
	;;
wallpapers)
	walker -t pywal --provider menus:wallpaper
	;;
themes)
	walker -t pywal --provider menus:themes
	;;
clipboard)
	walker -t pywal --provider clipboard
	;;
symbols)
	walker -t pywal --provider symbols
	;;
keybinds)
	walker -t pywal --provider menus:keybinds
	;;
calc)
	walker -t pywal --provider calc
	;;
web)
	walker -t pywal --provider websearch
	;;
runner | windows | help)
	walker -t pywal
	;;
esac
