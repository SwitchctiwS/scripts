#!/bin/bash

### WallPaper CHANGEr ###

# Description: Randomly changes wallpaper
# Author: Jared Thibault
# Date: 2019-04-04

# NOTE: The folder that the wallpapers are stored in should JUST HAVE PICTURES!
# anything else will crash nitrogen

# BUG: Technically, there is a slight chance that the same wallpaper will
# display again when making a new wallpaper lists file

# config files 
CONFIG_FILE="$HOME/.config/wpchange/config"
WP_LIST_FILE="$HOME/.config/wpchange/wallpaper_list"
CURRENT_WP_FILE="$HOME/.config/wpchange/current_wallpaper"

main() {
    if ! [[ -f "${CONFIG_FILE}" ]] || ! [[ -f "${WP_LIST_FILE}" ]] || ! [[ -f "${CURRENT_WP_FILE}" ]]; then
        create_config
    fi

    current_wp="$(read_current_wp)"
    echo "current wallpaper is $current_wp"
    wp_dir="$(read_wp_dir)"
    echo "wallpaper directory is $wp_dir"
    next_wp="$(get_next_wp "$current_wp" "$wp_dir")"

    # write new wallpaper to file
    echo "$next_wp" > "$CURRENT_WP_FILE"

    # actually set wallpaper
    echo "changing wallpaper to $next_wp"
    nitrogen --set-centered "$next_wp"
    
    exit 0
}

get_next_wp() {
    current_wp="$1"
    wp_dir="$2"

    next_wp_index=$(next_wp_index "$current_wp" "$wp_dir")
    # if this variable is 0, then it couldn't find the 
    # wallpaper or is the last wallpaper, so, create a new list
    if [[ "$next_wp_index" == "0" ]]; then
        create_wp_list "$wp_dir"
    fi

    # iterate through wallpaper list to find next
    i=0
    next_wp=""
    while read line; do
        if [[ "$i" == "$next_wp_index" ]]; then
            next_wp="$line"
        fi

        i=$(($i + 1))
    done < "$WP_LIST_FILE"

    # if the next file doesn't exist for some reason, just create a new list
    if ! [[ -f "$next_wp" ]]; then
        create_wp_list "$wp_dir"
        next_wp="$(head -n 1 $WP_LIST_FILE)"
    fi

    echo "$next_wp"
}

next_wp_index() {
    current_wp="$1"
    wp_dir="$2"

    # look through wallpaper list file
    wp_index=0
    i=0
    while read line; do
        if [[ "$line" == "$current_wp" ]]; then 
            wp_index=$(($i + 1))
        fi
        i=$(($i + 1))
    done < "$WP_LIST_FILE"

    # makes it empty if it's the last wallpaper in the file
    if [[ "$wp_index" == "$i" ]] || [[ "$wp_index" == "" ]]; then
        wp_index=0
    fi

    echo "$wp_index"
}

create_wp_list() {
    wp_dir="$1"

    rm "$WP_LIST_FILE"
    if [[ -f "$WP_LIST_FILE" ]]; then
        echo "could not delete $WP_LIST_FILE file!"
        echo 'do you have proper permissions?'
        exit 1
    fi
    
    # stores all filenames in array
    cd "$wp_dir"
    wps=(*)

    # exits if not enough wallpapers
    if [[ "${#wps[@]}" -le 1 ]]; then
        echo 'not enough wallpapers to change to!'
        echo 'need at least 2'
        exit 1
    fi

    # 0-indexed (so it's actually +1 for total)
    wps_total=$((( ${#wps[@]} - 1 )))

    # make wallpaper array random
    for i in $(seq $wps_total -1 0); do
        rand=$((($RANDOM % $(($i + 1)))))

        temp="${wps[$rand]}"
        wps[$rand]="${wps[$i]}"
        wps[$i]="${temp}"
    done

    # write to file
    for i in $(seq 0 $wps_total); do
        echo "${wp_dir}${wps[$i]}" >> "${WP_LIST_FILE}"
    done
}

create_config() {
    config_dir="$(dirname "$CONFIG_FILE")"

    if ! [[ -f "${CONFIG_FILE}" ]]; then
        echo "creating $CONFIG_FILE"
        mkdir -p "$config_dir"
        if ! [[ -d "$config_dir" ]]; then
            echo "failed to create directory $config_dir"
            exit 1
        fi
        cd "$config_dir"
        echo '# enter wallpaper directory here' >> "${CONFIG_FILE}"
        echo '#$HOME/Pictures/Wallpaper/' >> "${CONFIG_FILE}"
    fi

    if ! [[ -f "${CURRENT_WP_FILE}" ]]; then
        echo "creating $CURRENT_WP_FILE"
        echo '' >> "${CURRENT_WP_FILE}"
    fi

    if ! [[ -f "${WP_LIST_FILE}" ]]; then
        echo "creating $WP_LIST_FILE"
        echo '' >> "${WP_LIST_FILE}"
    fi
}


read_current_wp() {
    # reads current wallpaper
    # technically only reads the last line in the file
    while read line; do
        wp=$(echo "$line") 
    done < "$CURRENT_WP_FILE"

    echo "$wp"
}

read_wp_dir() {
    # reads wallpaper dir
    # also technically only reads last line in file
    while read line; do
        # expands $HOME
        wp_dir=$(echo "${line/'$HOME'/$HOME}") 
    done < "$CONFIG_FILE"
    if ! [[ -d "$wp_dir" ]]; then
        echo 'directory does not exist!'
        exit 1
    fi

    echo "$wp_dir"
}

# start here!
main
