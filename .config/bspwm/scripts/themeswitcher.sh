#!/bin/sh

source ~/.config/bspwm/scripts/themecontrol.sh
dir=~/.config/themeswitcher
totalthemes="$(ls -1 $dir/ | wc -l)"

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
    selection="$(echo "$currenttheme" | ~/.config/bspwm/scripts/themeselect.sh)"
    sed -i "s/^currenttheme=.*/currenttheme=\"$currenttheme\"/" ~/.config/bspwm/scripts/themecontrol.sh
    cp -a $selection/.config $selection/.icons $selection/.xsettingsd $selection/.fehbg ~/
    source ~/.config/bspwm/scripts/control.sh
    kitten themes --reload-in=all $themename &
    sed -i "s/theme =.*/theme = \"$themename\"/" ~/.config/nvim/lua/chadrc.lua ; nvim -c "| w" -c "qa" ~/.config/nvim/lua/chadrc.lua &
    killall dunst ; bspc wm -r
}

case $1 in
f) # cycle forwards
    echo "starting theme $currenttheme"
    currenttheme=$((currenttheme+1))
    if [ "$currenttheme" -gt "$totalthemes" ] ; then
        currenttheme="1"
    fi
    echo "now: $currenttheme"
    update $currenttheme ;;
b) # cycle backwards
    echo "starting theme $currenttheme"
    currenttheme=$((currenttheme-1))
    if [ "$currenttheme" -lt 1 ] ; then
        currenttheme="$totalthemes"
    fi
    echo "now: $currenttheme"
    update $currenttheme ;;
*) # update to selected theme / invalid option
    if [ -d $dir/$1 ]; then
        # Change theme files 
        cp -a $dir/$1/.config $dir/$1/.icons $dir/$1/.xsettingsd $dir/$1/.fehbg ~/ &
        kitten themes --reload-in=all $1 &
        sed -i "s/theme =.*/theme = \"$1\"/" ~/.config/nvim/lua/chadrc.lua ; nvim -c "| w" -c "qa" ~/.config/nvim/lua/chadrc.lua &
        # Restart programs
        killall dunst ; bspc wm -r 
    else # invalid option
        print_error
    fi
esac

sleep 0.1 && dunstify "t1" -a "  $themename $currenttheme/$totalthemes" -i "~/.config/dunst/icons/hyprdots.png" -r 91192 -t 2000
