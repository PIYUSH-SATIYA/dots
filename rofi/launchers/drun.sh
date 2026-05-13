#!/usr/bin/env bash

theme="$HOME/.config/rofi/theme.rasi"

query="${1:-}"

apps=$(find /usr/share/applications ~/.local/share/applications \
    -name "*.desktop" 2>/dev/null)

entries=$(
for file in $apps; do
    name=$(grep -m1 "^Name=" "$file" | cut -d= -f2)
    icon=$(grep -m1 "^Icon=" "$file" | cut -d= -f2)

    [[ -z "$name" ]] && continue

    echo -en "${name}\0icon\x1f${icon}\n"
done
)

chosen=$((
    echo "$entries"
    echo -en "󰖟 Search Google\n"
) | rofi \
    -dmenu \
    -i \
    -show-icons \
    -markup-rows \
    -p "Apps" \
    -theme "$theme")

[[ -z "$chosen" ]] && exit 0

if [[ "$chosen" == "󰖟 Search Google" ]]; then
    query=$(rofi -dmenu -p "Google Search")

    [[ -n "$query" ]] && \
        xdg-open "https://www.google.com/search?q=${query}"

    exit 0
fi

desktop=$(grep -rl "^Name=${chosen}$" \
    /usr/share/applications \
    ~/.local/share/applications 2>/dev/null | head -n1)

if [[ -n "$desktop" ]]; then
    gtk-launch "$(basename "$desktop" .desktop)"
else
    xdg-open "https://www.google.com/search?q=${chosen}"
fi
