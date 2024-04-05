#!/bin/sh

source ~/.config/bspwm/scripts/themecontrol.sh
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
exit
}

function update
{
    selection="$(echo "$currentbar" | ~/.config/bspwm/scripts/barselect.sh)"
    sed -i "s/^currentbar=.*/currentbar=\"$currentbar\"/" ~/.config/bspwm/scripts/control.sh
    cp -a $selection ~/.config/polybar/config.ini ; cp -a $selection ~/.config/themeswitcher/$themename/.config/polybar/config.ini &
    cp -a ~/.config/bspwm/scripts/control.sh ~/.config/themeswitcher/$themename/.config/bspwm/scripts/control.sh &
    if [ "$(awk '/^bottom/{print $NF}' ~/.config/polybar/config.ini)" = true ] ; then
	      sed -i "s/origin =.*/origin = top-right/" ~/.config/dunst/dunstrc ; killall dunst ;
	      cp -a ~/.config/dunst/dunstrc ~/.config/themeswitcher/$themename/.config/dunst/dunstrc &
    else
	      sed -i "s/origin =.*/origin = bottom-right/" ~/.config/dunst/dunstrc ; killall dunst ;
	      cp -a ~/.config/dunst/dunstrc ~/.config/themeswitcher/$themename/.config/dunst/dunstrc &
    fi
}

function refresh
{
    if pgrep -x polybar > /dev/null ; then
        if [ "$(awk '/^bottom/{print $NF}' ~/.config/polybar/config.ini)" = true ] ; then
	          bspc config top_padding 0 &
	          bspc config bottom_padding $(($(awk '/^height/{print $NF}' ~/.config/polybar/config.ini) + 2)) &
	      else
	          bspc config top_padding $(($(awk '/^height/{print $NF}' ~/.config/polybar/config.ini) + 2)) &
	          bspc config bottom_padding 0 &
	      fi
    fi
}

case $1 in
r) # refresh polybar
    if [ "$polybarenabled" = true ] ; then
        if pgrep -x polybar > /dev/null ; then
            refresh &
        else
            polybar -r &
	          refresh &
        fi
    fi
    exit ;;
t) # toggle polybar
    if pgrep -x polybar > /dev/null ; then
        sed -i "s/polybarenabled=.*/polybarenabled=false/" ~/.config/bspwm/scripts/themecontrol.sh &
        bspc config top_padding 0 &
	      bspc config bottom_padding 0 &
        killall polybar &
        notif=" Polybar disabled"
    else
        sed -i "s/polybarenabled=.*/polybarenabled=true/" ~/.config/bspwm/scripts/themecontrol.sh &
        polybar -r &
	      refresh &
        notif=" Polybar enabled"
    fi ;;
f) # cycle forwards
    currentbar=$((currentbar+1))
    if [ "$currentbar" -gt "$totalbars" ] ; then
        currentbar="1"
    fi
    update $currentbar ; refresh
    notif="    Polybar $currentbar/$totalbars" ;;
b) # cycle backwards
    currentbar=$((currentbar-1))
    if [ "$currentbar" -lt 1 ] ; then    
        currentbar="$totalbars"
    fi
    update $currentbar ; refresh
    notif="    Polybar $currentbar/$totalbars" ;;
*) # invalid option
    print_error ;;
esac

sleep 0.1 && dunstify "t1" -a "$notif" -i "~/.config/dunst/icons/hyprdots.png" -r 91194 -t 2000
