#!/bin/sh

function print_error
{
cat << "EOF"
./theme_switcher.sh <theme>
themes:
    catpuccin
    everforest
    gruvbox-dark
    gruvbox-light
    nord
EOF
}

dir=~/.config/themeswitcher
theme="$1"
if [ -d $dir/$theme ]; then
    # Notify
    sleep 0.2 && dunstify "t1" -a " $theme" -i "~/.config/dunst/icons/hyprdots.png" -r 91192 -t 2000 &
    # Change theme files 
    cp -a $dir/$theme/.config $dir/$theme/.icons $dir/$theme/.xsettingsd $dir/$theme/.fehbg ~/ &
    kitten themes --reload-in=all $theme &
    # Restart programs
    killall compfy ; killall dunst ; bspc wm -r 
else # invalid option
    print_error
fi

