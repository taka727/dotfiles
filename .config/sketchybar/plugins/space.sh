#!/bin/bash

ACTIVE_COLOR=0xff7aa2f7
INACTIVE_COLOR=0xff24283b
ACTIVE_BORDER=0xff7aa2f7
INACTIVE_BORDER=0xff414868
ACTIVE_LABEL=0xff1a1b26
INACTIVE_LABEL=0xff565f89

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" \
    background.color=$ACTIVE_COLOR \
    background.border_color=$ACTIVE_BORDER \
    icon.color=$ACTIVE_LABEL
else
  sketchybar --set "$NAME" \
    background.color=$INACTIVE_COLOR \
    background.border_color=$INACTIVE_BORDER \
    icon.color=$INACTIVE_LABEL
fi
