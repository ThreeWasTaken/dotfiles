#!/bin/bash

CONFIG_FILE="$HOME/.config/hypr/config/monitor.conf"
NORMAL_LAYOUT="#LAYOUT:normal"
GAMING_LAYOUT="#LAYOUT:gaming"

# Get current cursor position
cursor_x=$(hyprctl cursorpos | cut -d ',' -f1)
cursor_y=$(hyprctl cursorpos | cut -d ',' -f2)

# Get monitor under cursor
monitor_under_cursor=$(hyprctl monitors -j | jq -r \
  --arg x "$cursor_x" --arg y "$cursor_y" '
  .[] | select((.x <= ($x|tonumber)) and ((.x + .width) > ($x|tonumber)) and
               (.y <= ($y|tonumber)) and ((.y + .height) > ($y|tonumber)))
  | .name')

if grep -q "$NORMAL_LAYOUT" "$CONFIG_FILE"; then
    # Switch to gaming layout (with gaps)
    sed -i 's/^monitor=HDMI-A-1.*/monitor=HDMI-A-1, 1920x1080@60, 0x0, 1,/' "$CONFIG_FILE"
    sed -i 's/^monitor=DP-1.*/monitor=DP-1, 1920x1080@60, 2120x0, 1/' "$CONFIG_FILE"
    sed -i 's/^monitor=DP-2.*/monitor=DP-2, 1920x1080@60, 4240x0, 1,/' "$CONFIG_FILE"
    sed -i 's/^monitor=DP-3.*/monitor=DP-3, 1920x1080@60, 6360x0, 1/' "$CONFIG_FILE"
    sed -i "s/$NORMAL_LAYOUT/$GAMING_LAYOUT/" "$CONFIG_FILE"
    echo "🎮" > /tmp/hypr_monitor_mode  # Gaming mode

else
    # Switch to normal layout (no gaps)
    sed -i 's/^monitor=HDMI-A-1.*/monitor=HDMI-A-1, 1920x1080@60, 0x0, 1,/' "$CONFIG_FILE"
    sed -i 's/^monitor=DP-1.*/monitor=DP-1, 1920x1080@60, 1920x0, 1/' "$CONFIG_FILE"
    sed -i 's/^monitor=DP-2.*/monitor=DP-2, 1920x1080@60, 3840x0, 1,/' "$CONFIG_FILE"
    sed -i 's/^monitor=DP-3.*/monitor=DP-3, 1920x1080@60, 5760x0, 1/' "$CONFIG_FILE"
    sed -i "s/$GAMING_LAYOUT/$NORMAL_LAYOUT/" "$CONFIG_FILE"
    echo "🖥️" > /tmp/hypr_monitor_mode  # Normal mode
fi

# Reload Hyprland config
hyprctl reload

# Touch the monitor mode file to update timestamp (Waybar checks this)
touch /tmp/hypr_monitor_mode

# Refocus the monitor that originally had the cursor
if [ -n "$monitor_under_cursor" ]; then
    hyprctl dispatch focusmonitor "$monitor_under_cursor"
fi
