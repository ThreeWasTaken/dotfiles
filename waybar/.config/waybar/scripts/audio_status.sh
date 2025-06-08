#!/bin/bash

case "$(pactl get-default-sink)" in
  *SteelSeries*) echo "🎧" ;;
  *Pebble*) echo "🔊" ;;
  *hdmi*) echo "📺" ;;
  *) echo "❓" ;;
esac
