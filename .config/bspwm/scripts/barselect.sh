#!/bin/sh

PS3=""
select file in ~/.config/polybar/configs/*
do
    [[ -a "$file" ]] && break
done
echo "$file"

