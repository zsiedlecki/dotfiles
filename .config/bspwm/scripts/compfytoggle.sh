#!/bin/sh

if pgrep -x compfy > /dev/null ; then 
    killall compfy &
    notif=" Compfy disabled"
else 
    compfy --unredir-if-possible -b &
    notif=" Compfy enabled"
fi

sleep 0.1 && dunstify "t1" -a "$notif" -i "~/.config/dunst/icons/hyprdots.png" -r 91191 -t 2000
