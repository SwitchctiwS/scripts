#!/bin/bash

##################
# ============== #
# Volume Control #
# ============== #
##################

# Raises or lowers volume of default sink with pactl, but also clamps it to an upper/lower limit

# Useage:
# 	volume.sh <up|down>

# Config file stored in ~/.config/volume.conf
config_dir=~/.config/sound/
config_file='volume.conf'
config="${config_dir}${config_file}"

# Volume is saved to config file
cur_vol=""
cur_vol_file='current-volume'

# Creates file if none
function startup {
	mkdir -p "$config_dir"
	touch "$config"
	chmod 666 "$config"

	echo 'max="100"' >> "$config"
	echo 'min="0"' >> "$config"
	echo 'step="5"' >> "$config"
	echo 'init_sink_vol="50"' >> "$config"
	echo '' >> "$config"
}

function create_conf {
	touch "${config_dir}${cur_vol_file}.conf"
	chmod 666 "${config_dir}${cur_vol_file}.conf"

	echo '25' > "${config_dir}${cur_vol_file}.conf"
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
	elif [[ "$1" == "change-sink" ]]; then
		let cur_vol="$init_sink_vol"
	else
		exit 1
	fi

	pactl set-sink-volume @DEFAULT_SINK@ "$cur_vol"%
}

# main:
if ! [ -e "$config" ]; then
	startup
fi
source "$config"

if ! [ -e "${config_dir}${cur_vol_file}" ]; then
	create_conf
fi

cur_vol="$(<${config_dir}${cur_vol_file})"

change_volume "$1"

echo "$cur_vol" > "${config_dir}${cur_vol_file}"

exit 0

