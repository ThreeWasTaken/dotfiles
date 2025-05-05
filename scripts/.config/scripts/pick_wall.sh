#!/bin/bash

WALLPAPERS_DIR="$HOME/Images/Wallpapers"

if ! pgrep -x swww-daemon > /dev/null; then
  swww-daemon &
  sleep 0.3
fi

SELECTED=$(nsxiv -to "$WALLPAPERS_DIR"/*.jpg "$WALLPAPERS_DIR"/*.png)

[[ -z "$SELECTED" ]] && exit

swww img "$SELECTED" --transition-type any --transition-fps 60 --transition-duration 2
echo "$SELECTED" > /tmp/last_wallpaper.txt
