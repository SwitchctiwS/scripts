#!/bin/bash

##################
# ============== #
# Volume Control #
# ============== #
##################

# Raises or lowers volume with pactl, but also clamps it to an upper/lower limit

# Useage:
# 	volume.sh <default|headphones> <up|down>

# Config file stored in ~/.config/volume.conf
config_dir=~/.config/sound/
config_file='volume.conf'
config="${config_dir}${config_file}"

# Sink is chosen from config file
vol_sink=""

# Volume is saved to respective config file
cur_vol=""

# Creates file if none
function startup {
	mkdir -p "$config_dir"
	touch "$config"
	chmod 666 "$config"

	echo 'max="100"' >> "$config"
	echo 'min="0"' >> "$config"
	echo 'step="5"' >> "$config"
	echo '' >> "$config"
	echo '# sinks' >> "$config"
	echo 'default_sink="0"' >> "$config"
	echo '#headphones_sink=""' >> "$config"
}

function create_conf {
	touch "${config_dir}${1}.conf"
	chmod 666 "${config_dir}${1}.conf"
	echo '25' > "${config_dir}${1}.conf"
}

function choose_sink {
	if [[ "$1" == 'default' ]]; then
		vol_sink="$default_sink"
	elif [[ "$1" == 'headphones' ]]; then
		vol_sink="$headphones_sink"
	else
		exit 1
	fi
}

# Raises/lowers volume and clamps it to max/min
function change_volume {
	if [[ "$1" == 'up' ]]; then
		let cur_vol+="$step"
		if (( cur_vol > max )); then
			let cur_vol="$max"
		fi
	elif [[ "$1" == 'down' ]]; then
		let cur_vol-="$step"
		if (( cur_vol < min )); then
			let cur_vol="$min"
		fi
	else
		exit 1
	fi

	pactl set-sink-volume "$vol_sink" "$cur_vol"%
}

# main:
if ! [ -e "$config" ]; then
	startup
fi
source $config

if ! [ -e "${config_dir}${1}.conf" ]; then
	create_conf "$1"
fi
cur_vol="$(<${conf_dir}${1}.conf)"

choose_sink "$1"
change_volume "$2"

echo "$cur_vol" > "${config_dir}${1}.conf"

exit 0

# TODO
#	make just up/down affect everything
#	make it not automatically create a .conf with a random name
#		names should be predefined
# END TODO