#!/bin/bash

###
#
# i3 Config Change
#
###

# Program Description: Changes the i3 config file from my ergodox configuration to my normal (laptop) one.

# Usage: i3configchange.sh <ergodox|lapotop>

#main:
config_dir=~/.config/i3/
ergodox_config=config.ergodox
laptop_config=config.laptop

if [[ "${1}" == "ergodox" ]]; then
	cp ${config_dir}${ergodox_config} ${config_dir}config
elif [[ "${1}" == "laptop" ]]; then
	cp ${config_dir}${laptop_config} ${config_dir}config
else
	echo 'Unknown command'
	exit 1
fi

exit 0
