#!/bin/bash

echo "["
first=true
find ~/Images/Wallpapers -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.webp' \) | shuf -n 8 | while read -r path; do
  json_path=$(printf '%s' "$path" | jq -R .)
  if [ "$first" = true ]; then
    first=false
  else
    echo ","
  fi
  echo "$json_path"
done
echo "]"
