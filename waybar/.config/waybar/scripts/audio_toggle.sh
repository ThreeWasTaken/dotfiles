#!/bin/bash

SINK_FILE="$HOME/.cache/audio_sink_last"

HEADSET="alsa_output.usb-SteelSeries_Arctis_Nova_7-00.analog-stereo"
SPEAKER="alsa_output.usb-ACTIONS_Pebble_V3-00.analog-stereo"
HDMI="alsa_output.pci-0000_06_00.1.hdmi-stereo"
ALL_SINKS=("$HEADSET" "$SPEAKER" "$HDMI")
AVAILABLE_SINKS=()

EXISTING=$(pactl list short sinks | awk '{print $2}')
for sink in "${ALL_SINKS[@]}"; do
    if echo "$EXISTING" | grep -q "$sink"; then
        AVAILABLE_SINKS+=("$sink")
    fi
done

[ ${#AVAILABLE_SINKS[@]} -eq 0 ] && echo "❌ No available sinks" && exit 1

CURRENT=$(pactl get-default-sink)
[ -f "$SINK_FILE" ] && [[ " ${AVAILABLE_SINKS[*]} " =~ " $(cat "$SINK_FILE") " ]] && CURRENT=$(cat "$SINK_FILE")

if [ "$1" == "--switch" ]; then
    NEXT="${AVAILABLE_SINKS[0]}"
    for i in "${!AVAILABLE_SINKS[@]}"; do
        if [[ "${AVAILABLE_SINKS[$i]}" == "$CURRENT" ]]; then
            NEXT="${AVAILABLE_SINKS[$(( (i + 1) % ${#AVAILABLE_SINKS[@]} ))]}"
            break
        fi
    done
    pactl set-default-sink "$NEXT"
    echo "$NEXT" > "$SINK_FILE"

    pactl list short sink-inputs | while read -r line; do
        [[ -z "$line" ]] && continue
        INPUT_ID=$(echo "$line" | awk '{print $1}')
        pactl move-sink-input "$INPUT_ID" "$NEXT"
    done
else
    NEXT="$CURRENT"
fi

case "$NEXT" in
  *SteelSeries*) echo "🎧" ;;
  *Pebble*) echo "🔊" ;;
  *hdmi*) echo "📺" ;;
  *) echo "❓" ;;
esac
