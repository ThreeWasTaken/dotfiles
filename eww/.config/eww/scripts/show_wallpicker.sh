#!/bin/bash

# Ensure eww daemon is running
if ! pgrep -x "eww" > /dev/null; then
  eww daemon &
  sleep 0.3
fi

# Close existing instance first
eww close wallpicker

# Get 8 random wallpapers
wallpapers_json=$(~/.config/eww/scripts/get_wallpapers.sh)

# Update variable *before* opening
eww update wallpapers="$wallpapers_json"

# Wait a little longer to avoid race conditions
sleep 0.1

# Open the picker
eww open wallpicker

# Optional: Bring it to front (simulate a click to give it focus, if needed)
hyprctl dispatch focuswindow "eww" 2>/dev/null
