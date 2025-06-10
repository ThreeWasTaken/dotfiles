#!/bin/bash

# Define named sinks
HEADSET="alsa_output.usb-SteelSeries_Arctis_Nova_7-00.analog-stereo"
SPEAKER="alsa_output.usb-ACTIONS_Pebble_V3-00.analog-stereo"
HDMI="alsa_output.pci-0000_06_00.1.hdmi-stereo"

# Check which of the known sinks actually exist
ALL_SINKS=("$HEADSET" "$SPEAKER" "$HDMI")
AVAILABLE_SINKS=()

EXISTING=$(pactl list short sinks | awk '{print $2}')

for sink in "${ALL_SINKS[@]}"; do
    if echo "$EXISTING" | grep -q "$sink"; then
        AVAILABLE_SINKS+=("$sink")
    fi
done

if [ ${#AVAILABLE_SINKS[@]} -eq 0 ]; then
    echo "❌ No available sinks"
    exit 1
fi

CURRENT=$(pactl get-default-sink)
NEXT="${AVAILABLE_SINKS[0]}"

for i in "${!AVAILABLE_SINKS[@]}"; do
    if [[ "${AVAILABLE_SINKS[$i]}" == "$CURRENT" ]]; then
        NEXT_INDEX=$(( (i + 1) % ${#AVAILABLE_SINKS[@]} ))
        NEXT="${AVAILABLE_SINKS[$NEXT_INDEX]}"
        break
    fi
done

pactl set-default-sink "$NEXT"

pactl list short sink-inputs | while read -r line; do
    [[ -z "$line" ]] && continue
    INPUT_ID=$(echo "$line" | awk '{print $1}')
    pactl move-sink-input "$INPUT_ID" "$NEXT"
done

case "$NEXT" in
  *SteelSeries*) echo "🎧" ;;
  *Pebble*) echo "🔊" ;;
  *hdmi*) echo "📺" ;;
  *) echo "❓" ;;
esac
