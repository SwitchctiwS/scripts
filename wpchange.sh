#!/bin/bash

### WallPaper CHANGEr ###

# Description: Randomly changes wallpaper
# Author: Jared Thibault
# Date: 2019-04-04

# NOTE: The folder that the wallpapers are stored in should JUST HAVE PICTURES!
# anything else will crash nitrogen

# config files/dirs 
config="$HOME/.config/wpchange/config"
config_d="$(dirname "${config}")"
current_wp_f="$HOME/.config/wpchange/current_wallpaper"

# creates config file if it doesn't exist
if ! [[ -f "${config}" ]]; then
    mkdir -p "${config_d}"
    if ! [[ -d "$config_d" ]]; then
        echo 'failed to create directory!'
        exit 1
    fi
    cd "${config_d}"
    echo '# enter wallpaper directory here' >> "${config}"
    echo '#$HOME/Pictures/Wallpaper/' >> "${config}"
fi

# reads current wallpaper
# technically only reads the last line in the file
if ! [[ -f "${current_wp_f}" ]]; then
    echo '' >> "${current_wp_f}"
fi
while read line; do
    current_wp=$(eval "echo "${line}"")
done < "${current_wp_f}"

# reads wallpaper dir
# also technically only reads last line in file
while read line; do
    wp_dir=$(eval "echo "${line}"")
done < "${config}"
if ! [[ -d "${wp_dir}" ]]; then
    echo 'directory does not exist!'
    exit 1
fi

# stores all filenames in array
cd "${wp_dir}"
wps=(*)

# exits if not enough wallpapers
if [[ "${#wps[@]}" -le 1 ]]; then
    echo 'not enough wallpapers to change to!'
    echo 'need at least 2'
    exit 1
fi

wps_last_i=$((( ${#wps[@]} - 1 )))

# finds index of current wallpaper
current_wp_i=''
for i in $(seq 0 "$wps_last_i"); do
    if [[ "$(pwd)/${wps[$i]}" == "${current_wp}" ]]; then
        current_wp_i=$i
    fi
done

# finds new wallpaper index
new_wp_i=$((( $RANDOM % ${#wps[@]} )))
if ! [[ $current_wp == '' ]]; then
    while [ $new_wp_i -eq $current_wp_i ]; do
        new_wp_i=$((( $RANDOM % ${#wps[@]} )))
    done
fi

# writes new wallpaper
new_wp="$(pwd)/${wps[${new_wp_i}]}"
echo "${new_wp}" > "$current_wp_f"

# actually sets wallpaper
nitrogen --set-centered ${new_wp}
