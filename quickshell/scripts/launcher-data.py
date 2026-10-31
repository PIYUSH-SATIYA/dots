#!/usr/bin/env python3

import glob
import json
import os
import re
import subprocess
import sys
import unicodedata


def home():
    return os.environ.get("HOME", os.path.expanduser("~"))


def run(command, timeout=5):
    try:
        return subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None


def clean_exec(value):
    value = value.replace("%%", "\0")
    value = re.sub(r"%[fFuUdDnNickvm]", "", value)
    return value.replace("\0", "%").strip()


def read_desktop(path):
    data = {}
    section = ""

    try:
        with open(path, encoding="utf-8") as handle:
            for raw in handle:
                line = raw.rstrip("\n")
                if not line or line.startswith("#"):
                    continue
                if line.startswith("[") and line.endswith("]"):
                    section = line[1:-1]
                    continue
                if section != "Desktop Entry" or "=" not in line:
                    continue
                key, value = line.split("=", 1)
                if key not in data:
                    data[key] = value
    except OSError:
        return None

    return data


def applications():
    paths = []
    data_home = os.environ.get("XDG_DATA_HOME", os.path.join(home(), ".local/share"))
    data_dirs = os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":")

    paths.append(os.path.join(data_home, "applications"))
    paths.append(os.path.join(home(), ".local/share/flatpak/exports/share/applications"))
    paths.append("/var/lib/flatpak/exports/share/applications")

    for entry in data_dirs:
        if entry:
            paths.append(os.path.join(entry, "applications"))

    seen = set()
    items = []

    for directory in paths:
        for path in sorted(glob.glob(os.path.join(directory, "**/*.desktop"), recursive=True)):
            identifier = os.path.relpath(path, directory)

            if identifier in seen:
                continue

            seen.add(identifier)
            data = read_desktop(path)

            if not data or data.get("Type", "Application") != "Application":
                continue
            if data.get("NoDisplay", "false").lower() == "true":
                continue
            if data.get("Hidden", "false").lower() == "true":
                continue

            name = data.get("Name", "").strip()

            if not name:
                continue

            comment = data.get("Comment", "").strip()
            exec_value = clean_exec(data.get("Exec", ""))
            categories = data.get("Categories", "").replace(";", " ")
            icon = data.get("Icon", "application-x-executable").strip() or "application-x-executable"

            items.append({
                "kind": "app",
                "name": name,
                "subtitle": comment or exec_value,
                "icon": icon,
                "desktop": path,
                "exec": exec_value,
                "terminal": data.get("Terminal", "false").lower() == "true",
                "action": "app",
                "search": " ".join([name, comment, exec_value, categories]),
            })

    items.sort(key=lambda item: item["name"].lower())
    return items


def clipboard():
    result = run(["cliphist", "list"])

    if not result or result.returncode != 0:
        return []

    items = []

    for line in result.stdout.splitlines()[:100]:
        if "\t" not in line:
            continue

        identifier, preview = line.split("\t", 1)
        preview = preview.replace("\n", " ").strip()
        name = preview[:160] or "(empty clipboard entry)"

        items.append({
            "kind": "clipboard",
            "name": name,
            "subtitle": "Clipboard",
            "icon": "edit-paste",
            "action": "clipboard",
            "arg": identifier,
            "search": preview,
        })

    return items


def themes():
    entries = {}
    pattern = os.path.join(home(), ".config/themes/*/*.json")

    for path in glob.glob(pattern):
        name = os.path.basename(os.path.dirname(path))
        entries[name] = {
            "kind": "theme",
            "name": name,
            "subtitle": "Theme",
            "icon": "preferences-desktop-theme",
            "action": "theme",
            "arg": name,
            "search": name,
        }

    items = [entries[name] for name in sorted(entries, key=str.lower)]
    items.append({
        "kind": "theme",
        "name": "Wallpaper Theme",
        "subtitle": "Dynamic theme",
        "icon": "preferences-desktop-theme",
        "action": "dynamic",
        "arg": "",
        "search": "wallpaper theme dynamic",
    })
    return items


def wallpapers():
    root = os.path.join(home(), "Pictures/wallpapers")
    extensions = {".jpg", ".jpeg", ".png", ".webp"}

    if not os.path.isdir(root):
        return []

    items = []

    for path in glob.glob(os.path.join(root, "**/*"), recursive=True):
        if not os.path.isfile(path):
            continue
        if os.path.splitext(path)[1].lower() not in extensions:
            continue

        relative = os.path.relpath(path, root)

        items.append({
            "kind": "wallpaper",
            "name": relative,
            "subtitle": "Wallpaper",
            "icon": "image-x-generic",
            "action": "wallpaper",
            "arg": path,
            "search": relative,
        })

    items.sort(key=lambda item: item["name"].lower())
    return items


def windows():
    result = run(["hyprctl", "clients", "-j"], timeout=3)

    if not result or result.returncode != 0:
        return []

    try:
        clients = json.loads(result.stdout)
    except json.JSONDecodeError:
        return []

    items = []

    for client in clients:
        if not client.get("mapped", True):
            continue

        address = client.get("address", "")
        title = client.get("title", "").strip()
        class_name = client.get("class", "").strip()
        initial_class = client.get("initialClass", "").strip()
        workspace = client.get("workspace", {})
        workspace_name = workspace.get("name", "") if isinstance(workspace, dict) else ""
        name = title or class_name or initial_class

        if not address or not name:
            continue

        subtitle = class_name or initial_class or "Window"
        if workspace_name:
            subtitle = subtitle + " · " + str(workspace_name)

        items.append({
            "kind": "window",
            "name": name,
            "subtitle": subtitle,
            "icon": "preferences-system-windows",
            "action": "window",
            "arg": address,
            "search": " ".join([name, class_name, initial_class, str(workspace_name)]),
        })

    items.sort(key=lambda item: item["name"].lower())
    return items


def keybinds():
    result = run(["hyprctl", "binds", "-j"], timeout=3)

    if not result or result.returncode != 0:
        return []

    try:
        binds = json.loads(result.stdout)
    except json.JSONDecodeError:
        return []

    modifiers = [
        (1, "SHIFT"),
        (4, "CTRL"),
        (8, "ALT"),
        (64, "SUPER"),
    ]

    items = []

    for bind in binds:
        key = bind.get("key", "")
        description = bind.get("description", "") or "No description"
        dispatcher = bind.get("dispatcher", "")
        argument = bind.get("arg", "")
        mask = int(bind.get("modmask", 0) or 0)
        parts = [name for bit, name in modifiers if mask & bit]
        parts.append(key)
        combo = " + ".join(part for part in parts if part)
        search = " ".join([combo, description, dispatcher, argument])

        items.append({
            "kind": "keybind",
            "name": combo,
            "subtitle": description + " → " + dispatcher,
            "icon": "preferences-desktop-keyboard",
            "action": "copy",
            "arg": combo + "  " + description,
            "search": search,
        })

    items.sort(key=lambda item: item["name"].lower())
    return items


def symbols():
    ranges = [
        (0x1F300, 0x1FAFF),
        (0x1F000, 0x1F0FF),
        (0x2600, 0x27BF),
    ]
    items = []

    for start, end in ranges:
        for codepoint in range(start, end + 1):
            character = chr(codepoint)

            try:
                name = unicodedata.name(character)
            except ValueError:
                continue

            if not name:
                continue

            items.append({
                "kind": "symbol",
                "name": name.title(),
                "subtitle": "U+%04X" % codepoint,
                "icon": "",
                "glyph": character,
                "action": "copy",
                "arg": character,
                "search": name,
            })

    items.sort(key=lambda item: item["name"].lower())
    return items


def files(query):
    if not query.strip():
        return []

    result = run([
        "fd",
        "--type", "f",
        "--hidden",
        "--follow",
        "--exclude", ".git",
        "--exclude", "node_modules",
        "--exclude", ".cache",
        "--max-results", "40",
        "--absolute-path",
        "--color", "never",
        "--",
        query,
        home(),
    ], timeout=4)

    if not result or result.returncode not in (0, 1):
        return []

    items = []

    for path in result.stdout.splitlines()[:40]:
        if not path:
            continue

        items.append({
            "kind": "file",
            "name": os.path.basename(path),
            "subtitle": path,
            "icon": "text-x-generic",
            "action": "file",
            "arg": path,
            "search": path,
        })

    return items


def calculate(query):
    if not query.strip():
        return []

    result = run(["qalc", "-t", query], timeout=3)

    if not result or result.returncode != 0:
        return []

    value = " ".join(result.stdout.strip().splitlines()).strip()

    if not value:
        return []

    return [{
        "kind": "calc",
        "name": value,
        "subtitle": "Calculator",
        "icon": "accessories-calculator",
        "action": "copy",
        "arg": value,
        "search": query,
    }]


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "all"

    if mode == "apps":
        data = applications()
    elif mode == "clipboard":
        data = clipboard()
    elif mode == "themes":
        data = themes()
    elif mode == "wallpapers":
        data = wallpapers()
    elif mode == "keybinds":
        data = keybinds()
    elif mode == "windows":
        data = windows()
    elif mode == "symbols":
        data = symbols()
    elif mode == "files":
        data = files(sys.argv[2] if len(sys.argv) > 2 else "")
    elif mode == "calc":
        data = calculate(sys.argv[2] if len(sys.argv) > 2 else "")
    elif mode == "all":
        data = {
            "apps": applications(),
            "clipboard": clipboard(),
            "themes": themes(),
            "wallpapers": wallpapers(),
            "keybinds": keybinds(),
            "windows": windows(),
            "symbols": symbols(),
        }
    else:
        print(json.dumps([]))
        return

    print(json.dumps(data, ensure_ascii=False))


if __name__ == "__main__":
    main()
