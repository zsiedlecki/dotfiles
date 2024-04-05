#!/bin/sh

source $HOME/.config/bspwm/scripts/themecontrol.sh
dir=$HOME/.config/themeswitcher/
totalthemes="$(ls -1 $dir/ | wc -l)"
list=( `ls -w1 $dir` )

function print_error
{
cat << "EOF"
./themeswitcher.sh <action/theme>
actions:
    f : cycle theme forwards
    b : cycle theme backwards
themes:
    everforest
    gruvbox-dark
    gruvbox-light
    nord
EOF
exit
}

function update
{
    selection="$dir/${list[$currenttheme]}"
    sed -i "s/^currenttheme=.*/currenttheme=\"$currenttheme\"/" $HOME/.config/bspwm/scripts/themecontrol.sh
    cp -a $selection/.config $selection/.icons $selection/.xsettingsd $selection/.fehbg $HOME/ ;
    source $HOME/.config/bspwm/scripts/control.sh ;
    bspc wm -r &
    killall dunst &
    kitten themes --reload-in=all $themename &
    sed -i "s/theme =.*/theme = \"$themename\"/" $HOME/.config/nvim/lua/chadrc.lua ; nvim -c "| w" -c "qa" $HOME/.config/nvim/lua/chadrc.lua &
}

case $1 in
f) # cycle theme forwards
    currenttheme=$((currenttheme+1))
    if [ "$currenttheme" -ge "$totalthemes" ] ; then
        currenttheme="0"
    fi
    update $currenttheme ;;
b) # cycle theme backwards
    currenttheme=$((currenttheme-1))
    if [ "$currenttheme" -lt 0 ] ; then
      currenttheme="$((totalthemes-1))"
    fi
    update $currenttheme ;;
*) # invalid option
    print_error ;;
esac

sleep 0.1 && dunstify "t1" -a "  $themename $((currenttheme+1))/$totalthemes" -i "~/.config/dunst/icons/hyprdots.png" -r 91192 -t 2000
