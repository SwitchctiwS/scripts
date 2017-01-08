#!/bin/bash

##
# For changing/displaying the current monitor backlight settings in Wayland.
# Takes current brightness setting and brings it up/down by 1/20.
#
# Usage: backlight.sh <up|down|current>
##
dir=/sys/class/backlight/intel_backlight/
min_brightness=25
max_brightness=$(<$dir/max_brightness)
brightness=$(<$dir/brightness)

if ! [ -e $dir ]; then
	echo $dir 'does not exist!'
	exit 1
fi
if ! [ -e $dir'max_brightness' ]; then
	echo $dir'max_brightess does not exist!'
	exit 1
fi
if ! [ -e $dir'brightness' ]; then
	echo $dir'brightness does not exist!'
	exit 1
fi

scale=$((max_brightness / 20))

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
	echo 'Enter ONE argument'
	exit 1
fi

if [ $1 = 'up' ]; then
	let brightness+=$scale
	if [ $brightness -gt $max_brightness ]; then
		let brightness=$max_brightness
		echo 'Monitor is at max brightness'
	fi
elif [ $1 = 'down' ]; then
	let brightness-=$scale
	if [ $brightness -lt $min_brightness ]; then
		let brightness=$min_brightness
		echo 'Monitor is at min brightness'
	fi
elif [ $1 = 'current' ]; then
	echo 'Min: '$min_brightness 
	echo 'Max: '$max_brightness
	echo 'Current: '$brightness
else
	echo 'Enter "up", "down", or "current"' 
	exit 1
fi


echo $brightness > /sys/class/backlight/intel_backlight/brightness

exit 0

