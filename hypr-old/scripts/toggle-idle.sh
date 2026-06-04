#!/usr/bin/env bash

STATE_FILE="/tmp/hypridle-disabled"

if pgrep -x hypridle >/dev/null; then
  pkill hypridle
  touch "$STATE_FILE"
  notify-send "󰈈 Idle Disabled" "Screen timeout paused"
else
  rm -f "$STATE_FILE"
  hypridle &
  disown
  notify-send "󰛊 Idle Enabled" "Screen timeout active"
fi
