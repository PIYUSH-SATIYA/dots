#!/usr/bin/env bash

STATE=$(swaync-client -d)

if [ "$STATE" = "true" ]; then
  notify-send -u critical "DND Enabled"
else
  notify-send "DND Disabled"
fi
