#!/usr/bin/env python3
import json
import os
from pathlib import Path

HOME = Path.home()
WAL = HOME / ".cache/wal/colors.json"
OUT = HOME / ".config/theme-system/generated"


def clean(value):
    value = value.strip().lstrip("#").lower()
    if len(value) == 3:
        value = "".join(ch * 2 for ch in value)
    return value


def rgba(value, alpha="ff"):
    return f"rgba({clean(value)}{alpha})"


def blend(a, b, percent=60):
    a, b = clean(a), clean(b)
    ar, ag, ab = (int(a[i:i + 2], 16) for i in (0, 2, 4))
    br, bg, bb = (int(b[i:i + 2], 16) for i in (0, 2, 4))
    r = (ar * percent + br * (100 - percent)) // 100
    g = (ag * percent + bg * (100 - percent)) // 100
    bl = (ab * percent + bb * (100 - percent)) // 100
    return f"#{r:02x}{g:02x}{bl:02x}"


def write(name, text):
    path = OUT / name
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(text)
    os.replace(tmp, path)


def main():
    if not WAL.exists():
        raise SystemExit(f"theme-system: missing {WAL}")

    data = json.loads(WAL.read_text())
    colors = data["colors"]
    special = data.get("special", {})
    bg = special.get("background") or colors["color0"]
    fg = special.get("foreground") or colors["color15"]
    cursor = special.get("cursor") or fg
    accent = special.get("accent") or colors["color4"]

    OUT.mkdir(parents=True, exist_ok=True)

    definitions = [("foreground", fg), ("background", bg), ("cursor", cursor)]
    definitions += [(f"color{i}", colors.get(f"color{i}", fg)) for i in range(16)]
    definitions += [
        ("theme_fg_color", fg),
        ("theme_text_color", fg),
        ("theme_bg_color", bg),
        ("theme_base_color", bg),
        ("theme_selected_bg_color", accent),
        ("theme_selected_fg_color", bg),
        ("insensitive_fg_color", colors.get("color8", fg)),
        ("borders", colors.get("color8", fg)),
        ("warning_color", colors.get("color3", fg)),
        ("error_color", colors.get("color1", fg)),
        ("success_color", colors.get("color2", fg)),
    ]
    write("colors-gtk.css", "".join(
        f"@define-color {name} #{clean(value)};\n" for name, value in definitions
    ))

    write("hyprland.lua", (
        "return {\n"
        f'\tactive = "{rgba(bg)}",\n'
        f'\tactive_alt = "{rgba(accent)}",\n'
        f'\tinactive = "{rgba(colors.get("color8", bg), "aa")}",\n'
        "}\n"
    ))

    lock = [("background", bg), ("foreground", fg), ("cursor", cursor)]
    lock += [(f"color{i}", colors.get(f"color{i}", fg)) for i in range(16)]
    write("hyprlock.conf", "".join(
        f"${name} = {rgba(value)}\n" for name, value in lock
    ))

    theme = {
        "main_bg": bg,
        "main_fg": fg,
        "title": accent,
        "hi_fg": colors.get("color4", accent),
        "selected_bg": colors.get("color0", bg),
        "selected_fg": fg,
        "inactive_fg": colors.get("color8", fg),
        "graph_text": fg,
        "proc_misc": colors.get("color6", accent),
        "cpu_box": colors.get("color8", fg),
        "mem_box": colors.get("color8", fg),
        "net_box": colors.get("color8", fg),
        "proc_box": colors.get("color8", fg),
        "div_line": colors.get("color8", fg),
        "temp_start": colors.get("color2", accent),
        "temp_mid": colors.get("color3", accent),
        "temp_end": colors.get("color1", accent),
        "cpu_start": colors.get("color2", accent),
        "cpu_mid": colors.get("color3", accent),
        "cpu_end": colors.get("color1", accent),
        "free_start": colors.get("color1", accent),
        "free_mid": colors.get("color3", accent),
        "free_end": colors.get("color2", accent),
        "cached_start": colors.get("color4", accent),
        "cached_mid": colors.get("color6", accent),
        "cached_end": colors.get("color2", accent),
        "available_start": colors.get("color1", accent),
        "available_mid": colors.get("color3", accent),
        "available_end": colors.get("color2", accent),
        "used_start": colors.get("color2", accent),
        "used_mid": colors.get("color3", accent),
        "used_end": colors.get("color1", accent),
        "download_start": colors.get("color2", accent),
        "download_mid": colors.get("color6", accent),
        "download_end": colors.get("color4", accent),
        "upload_start": colors.get("color3", accent),
        "upload_mid": colors.get("color1", accent),
        "upload_end": colors.get("color5", accent),
        "process_start": colors.get("color2", accent),
        "process_mid": colors.get("color5", accent),
        "process_end": colors.get("color1", accent),
    }
    write("btop.theme", "".join(
        f'theme[{name}]="#{clean(value)}"\n' for name, value in theme.items()
    ))

    chromium = blend(bg, colors.get("color8", bg))
    write("chromium.json", json.dumps({
        "BrowserThemeColor": chromium,
        "BrowserColorScheme": "dark",
    }, indent=2) + "\n")


if __name__ == "__main__":
    main()
