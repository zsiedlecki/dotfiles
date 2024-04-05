#!/bin/sh

if pgrep -x picom > /dev/null ; then 
    killall picom &
    notif=" Picom disabled"
else 
    picom -b &
    notif=" Picom enabled"
fi

sleep 0.1 && dunstify "t1" -a "$notif" -i "~/.config/dunst/icons/hyprdots.png" -r 91191 -t 2000
