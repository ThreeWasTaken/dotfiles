#!/bin/bash

# Directories to check for cursor themes
icon_dirs=("$HOME/.icons" "/usr/share/icons")

# Get list of valid cursor themes
themes=()
for dir in "${icon_dirs[@]}"; do
    if [ -d "$dir" ]; then
        for subdir in "$dir"/*/; do
            [[ -d "$subdir/cursors" ]] && themes+=("$(basename "$subdir")")
        done
    fi
done

# Sort alphabetically
IFS=$'\n' sorted=($(sort <<<"${themes[*]}"))
unset IFS

# Get current cursor theme
current=$(gsettings get org.gnome.desktop.interface cursor-theme | sed "s/'//g")

# Direction: passed as an argument ("next" or "prev")
direction="$1"
[[ -z "$direction" ]] && direction="next"

# Find current index (case insensitive)
index=-1
for i in "${!sorted[@]}"; do
    theme_name="${sorted[$i],,}" # to lowercase
    current_name="${current,,}"  # to lowercase

    if [[ "$theme_name" == "$current_name" ]]; then
        index=$i
        break
    fi
done

# If not found, fallback to first
[[ $index -lt 0 ]] && index=0

theme_count=${#sorted[@]}

# Calculate next or previous index
if [[ "$direction" == "prev" ]]; then
    if [[ $index -eq 0 ]]; then
        new_index=$((theme_count - 1))
    else
        new_index=$((index - 1))
    fi
else
    new_index=$(( (index + 1) % theme_count ))
fi

new_cursor="${sorted[$new_index]}"

# Safety check: does the theme directory exist?
if [ ! -d "$HOME/.icons/$new_cursor" ] && [ ! -d "/usr/share/icons/$new_cursor" ]; then
    notify-send "Cursor switch failed" "Theme '$new_cursor' not found."
    exit 1
fi

# Apply new cursor theme
gsettings set org.gnome.desktop.interface cursor-theme "$new_cursor"
hyprctl setcursor "$new_cursor" 24

# Export for XWayland apps (e.g., Steam)
echo "export XCURSOR_THEME=$new_cursor" > ~/.cursor-env
echo "export XCURSOR_SIZE=24" >> ~/.cursor-env

# Notify user
notify-send "Cursor theme switched to:" "$new_cursor"
