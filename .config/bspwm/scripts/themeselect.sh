#!/bin/sh

PS3=""
select file in ~/.config/themeswitcher/*
do
  [[ -a "$file" ]] && break
done
echo "$file"

