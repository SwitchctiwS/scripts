#!/bin/bash
# TODO:	Update dirs, not just files
#	Have option to restore files
#	Read from config file

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
i3_src=~/.config/i3/
i3_dst=~/.dotfiles/arch/i3/
i3_fil=config

sway_src=~/.config/sway/
sway_dst=~/.dotfiles/arch/sway/
sway_fil=config

bashp_src=~/
bashp_dst=~/.dotfiles/arch/
bashp_fil=.bash_profile

xres_src=~/
xres_dst=~/.dotfiles/arch/
xres_fil=.Xresources

xtouchpad_src=/etc/X11/xorg.conf.d/
xtouchpad_dst=~/.dotfiles/arch/
xtouchpad_fil=50-synaptics.conf

i3status_src=~/.config/i3status/
i3status_dst=~/.dotfiles/arch/i3status/
i3status_fil=config

pro_src=~/
pro_dst=~/.dotfiles/arch/
pro_fil=.profile

fstab_src=/etc/
fstab_dst=~/.dotfiles/
fstab_fil=fstab
#
# Arrays of all src and dst
# Add files to this
#
srcs=($i3_src $sway_src $bashp_src $xres_src $xtouchpad_src $i3status_src $pro_src $fstab_src)
dsts=($i3_dst $sway_dst $bashp_dst $xres_dst $xtouchpad_dst $i3status_dst $pro_dst $fstab_dst)
fils=($i3_fil $sway_fil $bashp_fil $xres_fil $xtouchpad_fil $i3status_fil $pro_fil $fstab_fil)

i=0;

# Exits if srcs, dsts, fils don't match up
if (( ${#srcs[@]} != ${#dsts[@]} )) || (( ${#srcs[@]} != ${#fils[@]} )) || (( ${#dsts[@]} != ${#fils[@]} )); then
	echo -en '\E[31m'"\033[1m!! Error !! \033[0m"
	printf "Source, destination, or file directories are out-of-sync\n"
	exit 1
else
	let length=${#srcs[@]}
fi

# Copies and backs up config files in srcs/dsts
while (( i < length )); do
	printf "Files: "
	printf "\tsrc ${srcs[$i]}\n"
	printf "\tdst ${dsts[$i]}\n"
	printf "\tfil ${fils[$i]}\n"

	if [ -e ${srcs[$i]}${fils[$i]} ]; then
		# If dst dir doesn't exist, creates it
		if ! [ -e ${dsts[$i]} ]; then
			printf "Creating dst directory ..."
			mkdir -p ${dsts[$i]}
			if (($? == 0 )) && [ -e ${dsts[$i]} ]; then
				echo -e '\E[32m'"\033[1mDone\033[0m"
			else		
				echo -en '\E[31m'"\033[1m!! Error !! \033[0m"
				printf "Count not create dst directory\n"
				exit 1
			fi
		fi
		if [ -e ${dsts[$i]}${fils[$i]} ]; then
			# Checks if src and dst are the same
			# If true, doesn't copy
			cmp --silent ${srcs[$i]}${fils[$i]} ${dsts[$i]}${fils[$i]}
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
			mv ${dsts[$i]}${fils[$i]} ${dsts[$i]}${fils[$i]}.old
			if (( $? == 1 )) || ! [ -e ${dsts[$i]}${fils[$i]}.old ]; then
				printf "\n"
				echo -en '\E[31m'"\033[1m!! Error !! \033[0m"
				printf "Could not create dst.old\n"
				exit 1
			fi
			echo -e '\E[32m'"\033[1mDone\033[0m"
		fi

		# Copies src->dst
		printf "Copying src to dst ..."
		cp -r ${srcs[$i]}${fils[$i]} ${dsts[$i]}${fils[$i]}
		if (( $? == 1 )) || ! [ -e ${dsts[$i]}${fils[$i]} ]; then
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
