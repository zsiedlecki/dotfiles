#!/bin/sh

source ~/.config/bspwm/scripts/control.sh

PS3=""
select file in ~/.wallpapers/$themename/*
do
  [[ -a "$file" ]] && break
done
echo "$file"

