#!/bin/sh

source ~/.config/bspwm/scripts/control.sh
totalbars="$(ls -1 ~/.config/polybar/configs/ | wc -l)"

function print_error
{
cat << "EOF"
./polybar.sh <action>
actions:
    r : refresh polybar
    t : toggle polybar on/off
    f : cycle polybar forwards
    b : cycle polybar backwards
EOF
}

function update
{
    selection="$(echo "$currentbar" | ~/.config/bspwm/scripts/barselect.sh)"
    sed -i "s/^currentbar=.*/currentbar=\"$currentbar\"/" ~/.config/bspwm/scripts/control.sh
    cp -a $selection ~/.config/polybar/config.ini ; cp -a $selection ~/.config/themeswitcher/$currenttheme/.config/polybar/config.ini &
    cp -a ~/.config/bspwm/scripts/control.sh ~/.config/themeswitcher/$currenttheme/.config/bspwm/scripts/control.sh &
}

function refresh
{
    if pgrep -x polybar > /dev/null ; then
        if [ "$(awk '/^bottom/{print $NF}' ~/.config/polybar/config.ini)" = true ] ; then
	    echo "bar is on bottom"
	    sed -i "s/origin =.*/origin = top-right/" ~/.config/dunst/dunstrc ; killall dunst ;
	    cp -a ~/.config/dunst/dunstrc ~/.config/themeswitcher/$currenttheme/.config/dunst/dunstrc &
	    bspc config top_padding 0 &
	    bspc config bottom_padding $(($(awk '/^height/{print $NF}' ~/.config/polybar/config.ini) + 2)) &
	else
	    echo "bar is on top"
	    sed -i "s/origin =.*/origin = bottom-right/" ~/.config/dunst/dunstrc ; killall dunst ;
	    cp -a ~/.config/dunst/dunstrc ~/.config/themeswitcher/$currenttheme/.config/dunst/dunstrc &
	    bspc config top_padding $(($(awk '/^height/{print $NF}' ~/.config/polybar/config.ini) + 2)) &
	    bspc config bottom_padding 0 &
	fi
    fi
}

case $1 in
r) # refresh polybar
    if pgrep -x polybar > /dev/null ; then
        refresh &
	exit
    else
        polybar -r &
	refresh
	exit
    fi ;;
t) # toggle polybar
    if pgrep -x polybar > /dev/null ; then
        bspc config top_padding 0 &
	bspc config bottom_padding 0 &
        killall polybar &
        notif=" Polybar disabled"
    else
        polybar -r &
	refresh &
        notif=" Polybar enabled"
    fi ;;
f) # cycle forwards
    currentbar=$((currentbar+1))
    if [ "$currentbar" -gt "$totalbars" ] ; then
        currentbar="1"
    fi
    update $currentbar
    refresh
    notif="    Polybar $currentbar/$totalbars" ;;
b) # cycle backwards
    currentbar=$((currentbar-1))
    if [ "$currentbar" -lt 1 ] ; then    
        currentbar="$totalbars"
    fi
    update $currentbar
    refresh
    notif="    Polybar $currentbar/$totalbars" ;;
*) # invalid option
    print_error ;;
esac

sleep 0.1 && dunstify "t1" -a "$notif" -i "~/.config/dunst/icons/hyprdots.png" -r 91194 -t 2000