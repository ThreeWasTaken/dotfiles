#!/bin/bash

# Define sinks
HEADSET="alsa_output.usb-SteelSeries_Arctis_Nova_7-00.analog-stereo"
SPEAKER="alsa_output.usb-ACTIONS_Pebble_V3-00.analog-stereo"
HDMI="alsa_output.pci-0000_06_00.1.hdmi-stereo"

SINKS=("$HEADSET" "$SPEAKER" "$HDMI")
CURRENT=$(pactl get-default-sink)
NEXT_SINK="${SINKS[0]}"

for i in "${!SINKS[@]}"; do
    if [[ "${SINKS[$i]}" == "$CURRENT" ]]; then
        NEXT_INDEX=$(( (i + 1) % ${#SINKS[@]} ))
        NEXT_SINK="${SINKS[$NEXT_INDEX]}"
        break
    fi
done

# Switch default sink
pactl set-default-sink "$NEXT_SINK"

# Move all streams
pactl list short sink-inputs | while read -r line; do
    [[ -z "$line" ]] && continue
    INPUT_ID=$(echo "$line" | awk '{print $1}')
    pactl move-sink-input "$INPUT_ID" "$NEXT_SINK"
done

# Immediately output icon
case "$NEXT_SINK" in
  *SteelSeries*) echo "🎧" ;;
  *Pebble*) echo "🔊" ;;
  *hdmi*) echo "📺" ;;
  *) echo "❓" ;;
esac
