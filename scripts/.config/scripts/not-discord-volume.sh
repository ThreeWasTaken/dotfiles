#!/bin/bash

DELTA="$1"

# Get all sink input IDs except Discord's "WEBRTC VoiceEngine"
ids=$(pactl list sink-inputs | awk '
  $1 == "Sink" && $2 == "Input" && $3 ~ /#[0-9]+/ { sink_id = substr($3, 2); found=0 }
  /node.name = "WEBRTC VoiceEngine"/ { found=1 }
  found == 0 && /node.name/ { print sink_id }
')

for id in $ids; do
  pactl set-sink-input-volume "$id" "$DELTA"
done
