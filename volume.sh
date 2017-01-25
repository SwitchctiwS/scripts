#!/bin/bash

##################
# ============== #
# Volume Control #
# ============== #
##################

# Raises or lowers volume with pactl, but also clamps it to an upper/lower limit

# Useage:
# 	volume.sh <up|down|startup>

# Config file stored in ~/.config/volume.conf
config_dir=~/.config/sound/
config_file="volume.conf"
config="${config_dir}""${config_file}"

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

# Raises/lowers volume and clamps it to max/min
# Volume is saved to respective config file

vol_sink=""
cur_vol=""

function choose_sink {
	if [ "$1" == 'default' ]; then
		let vol_sink="$default_sink"
		let cur_vol="$default_vol"
	elif [ "$1" == 'headphones' ]; then
		let vol_sink="$headphones_sink"
		let cur_vol="$headphones_vol"
	else
		exit 1
	fi
}

function change_volume {
	if [ "$1" = 'up' ]; then
		let cur_vol+="$step"
		if (( cur_vol > max_vol )); then
			let cur_vol="$max"
		fi
		pactl set-sink-volume "$vol_sink" "$cur_vol"%
	elif [ "$1" = 'down' ]; then
		let cur_vol-="$step"
		if (( cur_vol < min_vol )); then
			let cur_vol="$min_vol"
		fi
		pactl set-sink-volume "$vol_sink" "$cur_vol"%
	else
		exit 1
	fi
	
	echo "$cur_vol" > '"$config_dir""$1".conf'
}

# main:
if ! [ -e "$config" ]; then
	startup
fi
source $config

if [ "$1" == 'default' ]; then
	vol_sink default
elif [ "$1" == 'headphones' ]; then
	vol_sink headphones
fi

exit 0
