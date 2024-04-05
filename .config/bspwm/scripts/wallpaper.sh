#!/bin/sh

source $HOME/.config/bspwm/scripts/control.sh
totalwalls="$(ls -1 $HOME/.wallpapers/$themename/ | wc -l)"
list=( `ls -w1 $HOME/.wallpapers/$themename/` )

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
    old="$HOME/.wallpapers/$themename/${list[$previouswall]}"
    new="$HOME/.wallpapers/$themename/${list[$currentwall]}"
    dunstify "t1" -a "    Wallpaper $((currentwall+1))/$totalwalls" -i "$new" -r 91193 -t 2000 &
    feh --bg-scale $new ; cp -a $HOME/.fehbg $HOME/.config/themeswitcher/$themename/.fehbg & 
    sed -i "s/^currentwall=.*/currentwall=\"$currentwall\"/" $HOME/.config/bspwm/scripts/control.sh ;
    cp -a $HOME/.config/bspwm/scripts/control.sh $HOME/.config/themeswitcher/$themename/.config/bspwm/scripts/control.sh &
}

case $1 in
f) # cycle wallpaper forwards
    previouswall=$currentwall
    currentwall=$((currentwall+1))
    if [ "$currentwall" -ge "$totalwalls" ] ; then
	      currentwall="0"
    fi
    update $currentwall $previouswall;;
b) # cycle wallpaper backwards
    previouswall=$currentwall
    currentwall=$((currentwall-1))
    if [ "$currentwall" -lt 0 ] ; then
      currentwall="$((totalwalls-1))"
    fi
    update $currentwall $previouswall;;
*) # invalid option
    print_error ;;
esac
