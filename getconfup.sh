#!/bin/bash
# TODO:	Update dirs, not just files
#	Have option to restore files

###########################
### Config File Updater ###
###########################

##
# This program automatically copies and backs up the listed config files 
##


#
# Config files' sources and destinations
# Add files to this
#
i3_src=~/.config/i3/config
i3_dst=~/.dotfiles/arch/i3/config

sway_src=~/.config/sway/config
sway_dst=~/.dotfiles/arch/sway/config

bashp_src=~/.bash_profile
bashp_dst=~/.dotfiles/arch/.bash_profile

xres_src=~/.Xresources
xres_dst=~/.dotfiles/arch/.Xresources

xtouchpad_src=/etc/X11/xorg.conf.d/70-synaptics.conf
xtouchpad_dst=~/.dotfiles/arch/70-synaptics.conf

#
# Arrays of all src and dst
# Add files to this
#
srcs=($i3_src $sway_src $bashp_src $xres_src $xtouchpad_src)
dsts=($i3_dst $sway_dst $bashp_dst $xres_dst $xtouchpad_dst)

i=0;

# Exits if srcs and dsts don't match up
if (( ${#srcs[@]} != ${#dsts[@]} )); then
	echo -en '\E[31m'"\033[1m!! Error !! \033[0m"
	printf "Source and destination directories are out-of-sync\n"
	exit 1
else
	let length=${#srcs[@]}
fi

# Copies and backs up config files in srcs/dsts
while (( i < length )); do
	printf "Files: "
	printf "\tsrc ${srcs[$i]}\n"
	printf "\tdst ${dsts[$i]}\n"
	if [ -e ${srcs[$i]} ]; then
		if [ -e ${dsts[$i]} ]; then
			# Checks if src and dst are the same
			# If true, doesn't copy
			cmp --silent ${srcs[$i]} ${dsts[$i]}
			if (( $? == 0 )); then
				echo -en '\E[33m'"\033[1m!! Warning !! \033[0m"
				printf "Not copying: src file and dst file have identical contents\n"
				printf "\n"
				let i++
				continue
			fi

			# Makes *.old backup if none
			# Replaces if there is one
			printf "Creating dst.old ..."
			mv ${dsts[$i]} ${dsts[$i]}.old
			if (( $? == 1 )) || ! [ -e ${dsts[$i]}.old ]; then
				printf "\n"
				echo -en '\E[31m'"\033[1m!! Error !! \033[0m"
				printf "Could not create dst.old\n"
				exit 1
			fi
			echo -e '\E[32m'"\033[1mDone\033[0m"
		fi

		# Copies src->dst
		printf "Copying src to dst ..."
		cp -r ${srcs[$i]} ${dsts[$i]}
		if (( $? == 1 )) || ! [ -e ${dsts[$i]} ]; then
			printf "\n"
			echo -en '\E[31m'"\033[1m!! Error !! \033[0m"
			printf "Could not copy src\n"
			exit 1
		fi
		echo -e '\E[32m'"\033[1mDone\033[0m"
	else
		# Will NOT exit if config file isn't found
		# This is so it will work on different systems
		# e.g. I may not have Sway on one system, but I
		# have i3. I don't want the program to keep 
		# exiting just because I don't have Sway
		echo -en '\E[31m'"\033[1m!! Error !! \033[0m"
		printf "Could not find src\n"
	fi
	
	printf "\n"
	let i++
done

exit 0
