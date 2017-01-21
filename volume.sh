#!/bin/bash

##################
# ============== #
# Volume Control #
# ============== #
##################

# Raises or lowers volume with pactl, but also clamps it to an upper/lower limit

# Useage:
# 	volume.sh <up|down|startup>

#	config file stored in ~/.config/volume.conf

# Edit:
# File location
CONF_DIR=~/.config/
CONF_FIL=volume.conf

# Claping values
MAX_VOL=100
MIN_VOL=0

STARTUP_VOL=25 # Volume computer starts up at
STEP=5 # Volume STEP % (e.g. +5%)
SINK='alsa_output.pci-0000_00_1b.0.analog-stereo' # Volume SINK to up/down

# Creates file if none
if ! [ -e ${CONF_DIR}${CONF_FIL} ]; then
	mkdir -p ${CONF_DIR}
	touch ${CONF_DIR}${CONF_FIL}
	chmod 666 ${CONF_DIR}${CONF_FIL}
	echo 25 > ${CONF_DIR}${CONF_FIL}
fi

# Raises/lowers volume and clamps it to max/min
# Volume is saved to config file
CUR_VOL=$(<${CONF_DIR}${CONF_FIL})
if [ "$1" = 'up' ]; then
	let CUR_VOL+=${STEP}
	if (( CUR_VOL > MAX_VOL )); then
		let CUR_VOL=${MAX_VOL}
	fi
	pactl set-sink-volume ${SINK} ${CUR_VOL}%
elif [ "$1" = 'down' ]; then
	let CUR_VOL-=${STEP}
	if (( CUR_VOL < MIN_VOL )); then
		let CUR_VOL=${MIN_VOL}
	fi
	pactl set-sink-volume ${SINK} ${CUR_VOL}%
elif [ "$1" = 'startup' ]; then
	let CUR_VOL=${STARTUP_VOL}
	pactl set-sink-volume ${SINK} ${CUR_VOL}%
else
	exit 1
fi

echo ${CUR_VOL} > ${CONF_DIR}${CONF_FIL}

exit 0

