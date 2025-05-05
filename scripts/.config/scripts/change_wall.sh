#!/bin/bash

# Start swww-daemon if not running
if ! pgrep -x swww-daemon > /dev/null; then
  swww-daemon &
  sleep 0.3
fi

WALLPAPERS_DIR="$HOME/Images/Wallpapers/"
LAST_USED_FILE="/tmp/last_wallpaper.txt"

# Get current wallpaper path if known
LAST_USED=""
if [[ -f "$LAST_USED_FILE" ]]; then
  LAST_USED=$(<"$LAST_USED_FILE")
fi

# Get a new wallpaper, different from the last one
WALL_LIST=($(find -L "$WALLPAPERS_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \)))

# Fallback check
if [[ ${#WALL_LIST[@]} -eq 0 ]]; then
  echo "❌ No wallpapers found in $WALLPAPERS_DIR"
  exit 1
fi

# Keep picking until it's different (or only one wallpaper exists)
RANDOM_WALL="$LAST_USED"
if [[ ${#WALL_LIST[@]} -gt 1 ]]; then
  while [[ "$RANDOM_WALL" == "$LAST_USED" ]]; do
    RANDOM_WALL=$(shuf -e "${WALL_LIST[@]}" -n 1)
  done
else
  RANDOM_WALL="${WALL_LIST[0]}"
fi

# Save the new wallpaper path
echo "$RANDOM_WALL" > "$LAST_USED_FILE"

# Set the wallpaper
echo "🎨 Changing wallpaper to: $RANDOM_WALL"
swww img "$RANDOM_WALL" --transition-type any --transition-fps 60 --transition-duration 2
