#!/bin/bash

WALLPAPER_DIR="$HOME/Images/Wallpapers"

# Make sure swww is running
if ! pgrep -x swww-daemon > /dev/null; then
  swww-daemon &
  sleep 0.5
fi

# Get list of wallpapers
selected=$(find "$WALLPAPER_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.webp' \) \
  | sed "s|$WALLPAPER_DIR/||" \
  | rofi -dmenu -p "Select Wallpaper")

# Exit if none selected
[[ -z "$selected" ]] && exit

# Full path to wallpaper
wall="$WALLPAPER_DIR/$selected"

# Set wallpaper with animation
swww img "$wall" --transition-type any --transition-fps 60 --transition-duration 2

# Save path to last used file
echo "$wall" > /tmp/last_wallpaper.txt
