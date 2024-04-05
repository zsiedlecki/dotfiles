#!/bin/sh

source $HOME/.config/bspwm/scripts/themecontrol.sh
source $HOME/.config/bspwm/scripts/control.sh
totalbars="$(ls -1 $HOME/.config/polybar/configs/ | wc -l)"
list=( `ls -w1 $HOME/.config/polybar/configs/` )

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
    selection="$HOME/.config/polybar/configs/${list[$currentbar]}"
    sed -i "s/^currentbar=.*/currentbar=\"$currentbar\"/" $HOME/.config/bspwm/scripts/control.sh ;
    cp -a $selection ~/.config/polybar/config.ini ; cp -a $selection $HOME/.config/themeswitcher/$themename/.config/polybar/config.ini &
    cp -a $HOME/.config/bspwm/scripts/control.sh $HOME/.config/themeswitcher/$themename/.config/bspwm/scripts/control.sh &
    if [ "$(awk '/^bottom/{print $NF}' $HOME/.config/polybar/config.ini)" = true ] ; then
	      sed -i "s/origin =.*/origin = top-right/" $HOME/.config/dunst/dunstrc ; killall dunst ;
	      cp -a $HOME/.config/dunst/dunstrc $HOME/.config/themeswitcher/$themename/.config/dunst/dunstrc &
    else
	      sed -i "s/origin =.*/origin = bottom-right/" $HOME/.config/dunst/dunstrc ; killall dunst ;
	      cp -a $HOME/.config/dunst/dunstrc $HOME/.config/themeswitcher/$themename/.config/dunst/dunstrc &
    fi
}

function refresh
{
    if pgrep -x polybar > /dev/null ; then
        if [ "$(awk '/^bottom/{print $NF}' $HOME/.config/polybar/config.ini)" = true ] ; then
	          bspc config top_padding 0 &
	          bspc config bottom_padding $(($(awk '/^height/{print $NF}' $HOME/.config/polybar/config.ini) + 2)) &
	      else
	          bspc config top_padding $(($(awk '/^height/{print $NF}' $HOME/.config/polybar/config.ini) + 2)) &
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
        sed -i "s/polybarenabled=.*/polybarenabled=false/" $HOME/.config/bspwm/scripts/themecontrol.sh &
        bspc config top_padding 0 &
	      bspc config bottom_padding 0 &
        killall polybar &
        notif=" Polybar disabled"
    else
        sed -i "s/polybarenabled=.*/polybarenabled=true/" $HOME/.config/bspwm/scripts/themecontrol.sh &
        polybar -r &
	      refresh &
        notif=" Polybar enabled"
    fi ;;
f) # cycle forwards
    currentbar=$((currentbar+1))
    if [ "$currentbar" -ge "$totalbars" ] ; then
        currentbar="0"
    fi
    update $currentbar ; refresh ;
    notif="    Polybar $((currentbar+1))/$totalbars" ;;
b) # cycle backwards
    currentbar=$((currentbar-1))
    if [ "$currentbar" -lt 0 ] ; then    
      currentbar="$((totalbars-1))"
    fi
    update $currentbar ; refresh ;
    notif="    Polybar $((currentbar+1))/$totalbars" ;;
*) # invalid option
    print_error ;;
esac

sleep 0.1 && dunstify "t1" -a "$notif" -i "$HOME/.config/dunst/icons/hyprdots.png" -r 91194 -t 2000
