#!/bin/bash

#TODO: figure out how to connect headphones

################
# Sound Output #
################

# Changes sound output from laptop, HDMI, headphones and vice versa

# Useage:
#	sound-output.sh <laptop|hdmi|headphones>

# BUG:
# udev detects an HDMI plug in, but it doesn't detect when it's unplugged!
# xrandr will "refresh" udev and make it realize it's disconnected
xrandr > /dev/null

HDMI_STATUS=$(</sys/class/drm/*HDMI*/status)
if [ "$1" = 'hdmi' ] && [ "${HDMI_STATUS}" = 'connected' ]; then
	pactl move-sink-input 0 alsa_output.pci-0000_00_03.0.hdmi-stereo
	pactl set-sink-volume alsa_output.pci-0000_00_03.0.hdmi-stereo 100%
elif [ "$1" = 'laptop' ]; then
	pactl move-sink-input 0 alsa_output.pci-0000_00_1b.0.analog-stereo
#elif [ "$1" = 'headphones' ]; then
	#figure this out 
else
	exit 1
fi

exit 0
