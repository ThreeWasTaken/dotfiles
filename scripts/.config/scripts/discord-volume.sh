#!/bin/bash

DELTA="$1"

# Find the ID of the sink input with node.name = "WEBRTC VoiceEngine"
id=$(pactl list sink-inputs | awk '
  $1 == "Sink" && $2 == "Input" && $3 ~ /#[0-9]+/ { sink_id = substr($3, 2) }
  /node.name = "WEBRTC VoiceEngine"/ { print sink_id }
')

if [[ "$id" =~ ^[0-9]+$ ]]; then
  pactl set-sink-input-volume "$id" "$DELTA"
else
  notify-send "Discord stream not found (WEBRTC VoiceEngine)"
fi
