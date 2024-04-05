#!/bin/sh

source ~/.config/bspwm/scripts/control.sh
totalwalls="$(ls -1 ~/.wallpapers/$themename/ | wc -l)"

function print_error
{
cat << "EOF"
./wallpaper.sh <action>
actions:
    f : cycle wallpaper forwards
    b : cycle wallpaper backwards
EOF
exit
}

function update
{
    selection="$(echo "$currentwall" | ~/.config/bspwm/scripts/wallselect.sh)"
    sed -i "s/^currentwall=.*/currentwall=\"$currentwall\"/" ~/.config/bspwm/scripts/control.sh
    feh --bg-scale $selection ; cp -a ~/.fehbg ~/.config/themeswitcher/$themename/.fehbg &
    cp -a ~/.config/bspwm/scripts/control.sh ~/.config/themeswitcher/$themename/.config/bspwm/scripts/control.sh &
}

case $1 in
f) # cycle forwards
    currentwall=$((currentwall+1))
    if [ "$currentwall" -gt "$totalwalls" ] ; then
	      currentwall="1"
    fi
    update $currentwall ;;
b) # cycle backwards
    currentwall=$((currentwall-1))
    if [ "$currentwall" -lt 1 ] ; then
	      currentwall="$totalwalls"
    fi
    update $currentwall ;;
*) # invalid option
    print_error ;;
esac

dunstify "t1" -a "    Wallpaper $currentwall/$totalwalls" -i "$selection" -r 91193 -t 2000
