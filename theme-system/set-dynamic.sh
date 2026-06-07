#!/bin/bash

set -e

HOME_DIR="$HOME"

echo "dynamic" \
  >"$HOME_DIR/.config/theme-system/mode"

"$HOME_DIR/.config/theme-system/apply-theme.sh"
