#!/bin/bash

###            ###
#                #
# Volume Control #
#                #
###            ###

# Raises or lowers volume with pactl, but also clamps it to an upper/lower limit

# Useage:
# 	volume.sh <up|down|startup>

#	config file stored in ~/.config/volume.conf

# Edit:
# File location
conf_dir=~/.config/
conf_fil=volume.conf

# Claping values
max_vol=100
min_vol=0

startup_vol=25 # Volume computer starts up at
step=5 # Volume step % (e.g. +5%)
sink_num=1 # Volume sink to up/down

# Creates file if none
if ! [ -e $conf_dir$conf_fil ]; then
	mkdir -p $conf_dir
	touch $conf_dir$conf_fil
	chmod 666 $conf_dir$conf_fil
	echo 25 > $conf_dir$conf_fil
fi

# Raises/lowers volume and clamps it to max/min
# Volume is saved to config file
cur_vol=$(<$conf_dir$conf_fil)
if [ $1 = 'up' ]; then
	let cur_vol+=$step
	if (( cur_vol > max_vol )); then
		let cur_vol=$max_vol
	fi
	pactl set-sink-volume $sink_num $cur_vol%
elif [ $1 = 'down' ]; then
	let cur_vol-=$step
	if (( cur_vol < min_vol )); then
		let cur_vol=$min_vol
	fi
	pactl set-sink-volume $sink_num $cur_vol%
elif [ $1 = 'startup' ]; then
	let cur_vol=$startup_vol
	pactl set-sink-volume $sink_num $cur_vol%
else
	exit 1
fi

echo $cur_vol > $conf_dir$conf_fil

exit 0

