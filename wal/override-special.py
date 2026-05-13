#!/usr/bin/env python3
import json
from pathlib import Path
WAL_JSON = Path.home() / ".cache" / "wal" / "colors.json"
if not WAL_JSON.exists():
    raise SystemExit("colors.json not found")
data = json.loads(WAL_JSON.read_text())
# Force a balanced dark base and readable foreground
data["special"]["background"] = "#101317"
data["special"]["foreground"] = "#e6e6e6"
data["special"]["cursor"] = "#e6e6e6"
WAL_JSON.write_text(json.dumps(data, indent=2) + "\n")
