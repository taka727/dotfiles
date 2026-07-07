#!/bin/bash

VOLUME=$(osascript -e "output volume of (get volume settings)")

if [ "$VOLUME" = "0" ]; then
  ICON="󰖁"
elif [ "$VOLUME" -lt 34 ]; then
  ICON="󰕿"
elif [ "$VOLUME" -lt 67 ]; then
  ICON="󰖀"
else
  ICON="󰕾"
fi

sketchybar --set "$NAME" icon="$ICON" label="${VOLUME}%"
