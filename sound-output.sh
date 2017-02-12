#!/bin/bash

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

# Config file:
config_dir=~/.config/sound/
config_file='sound-output.conf'
config="${config_dir}${config_file}"

# HDMI (dis)connected
hdmi_status="$(</sys/class/drm/*HDMI*/status)"

function move_stream {
	pactl list short sink-inputs | while read stream; do
		stream_id=$(echo $stream | cut -f 1)
		pactl move-sink-input "$stream_id" "$1"
	done
}

function startup {
	mkdir -p "$config_dir"
	touch "$config"
	chmod 666 $config

	echo 'computer="0"' >> $config
	echo '#hdmi=""' >> $config
	echo '#headphones=""' >> $config
}

function change_output {
	if [[ "$1" == 'hdmi' ]] && [ "$hdmi_status" = 'connected' ]; then
		move_stream $hdmi
		pactl set-default-sink $hdmi
		pactl set-sink-volume $hdmi 100%
	elif [[ "$1" == 'computer' ]]; then
		pactl set-default-sink $computer
		volume.sh change-sink
		move_stream $computer
	elif [[ "$1" == 'headphones' ]]; then
		pactl set-default-sink $headphones
		volume.sh change-sink
		move_stream $headphones	
	else
		exit 1
	fi

}

# main:
if ! [ -e "$config" ]; then
	startup
fi
source "$config"

change_output "$1"

exit 0
