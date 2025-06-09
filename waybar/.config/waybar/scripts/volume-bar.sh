#!/bin/bash

is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo "yes" || echo "no")

if [ "$is_muted" = "yes" ]; then
  echo -n '{"text": "", "tooltip": "Muted"}'
  exit 0
fi


blocks=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

get_block() {
  local vol=$1
  local default_color=$2

  if [[ -z "$vol" || "$vol" -lt 1 ]]; then
    echo "<span color='red'>▁</span>"
    return
  fi

  local clipped=$(( vol > 100 ? 100 : vol ))
  local index=$(( clipped * (${#blocks[@]} - 1) / 100 ))
  local color=$([[ $vol -gt 100 ]] && echo "red" || echo "$default_color")

  echo "<span color='$color'>${blocks[$index]}</span>"
}

# System (Main Sink)
main_vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
main_block=$(get_block "$main_vol" "white")

# Discord
discord_vol=$(pactl list sink-inputs | \
  grep -B50 'node.name = "WEBRTC VoiceEngine"' | \
  grep "Volume:" | head -n1 | grep -oP '\d+(?=%)' | head -n1)
discord_block=$(get_block "${discord_vol:-0}" "mediumpurple")

# Everything else (not Discord)
other_vol=$(pactl list sink-inputs | awk '
  BEGIN { discord = 0 }
  /^Sink Input/ { id = ""; skip = 0 }
  $1 == "Sink" && $2 == "Input" && $3 ~ /#[0-9]+/ { id = substr($3, 2) }
  /node.name = "WEBRTC VoiceEngine"/ { skip = 1 }
  /Volume:/ && !skip && id != "" {
    if (match($0, /([0-9]+)%/, m)) {
      print m[1]; exit
    }
  }
')
other_block=$(get_block "${other_vol:-0}" "#a6e3a1")

# Order: system | other | discord
echo "{\"text\": \"$main_block$other_block$discord_block\", \"tooltip\": \"Volume: ${main_vol}% / Other: ${other_vol:-off}% / Discord: ${discord_vol:-off}%\"}"
