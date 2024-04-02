#!/bin/sh

function print_error
{
cat << "EOF"
./screenshot.sh <action>
actions:
    p : print screen
    s : select from current screen
EOF
}

save_file=$(date +"%F_%T.png")

case $1 in
p) # print screen
    scrot -q 100 -Z 0 ~/Pictures/Screenshots/$save_file ;;
s) # drag to manually snip an area / click on a window to print it
    scrot -s -f -q 100 -Z 0 ~/Pictures/Screenshots/$save_file ;;
*) # invalid option
    print_error ;;
esac

if [ -f ~/Pictures/Screenshots/$save_file ] ; then
    sleep 0.1 && dunstify "t1" -a "Screenshot Saved" -i "~/Pictures/Screenshots/$save_file" -r 91195 -t 2000
fi
