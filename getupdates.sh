#!/bin/sh

i3_source=~/.config/i3/config
i3_dest=~/.dotfiles/arch/i3/config

sway_source=~/.config/sway/config
sway_dest=~/.dotfiles/arch/sway/config

bashp_source=~/.bash_profile
bashp_dest=~/.dotfiles/arch/.bash_profile

xres_source=~/.Xresources
xres_dest=~/.dotfiles/arch/.Xresources

xtouchpad_source=/etc/X11/xorg.conf.d/70-synaptics.conf
xtouchpad_dest=~/.dotfiles/arch/70-synaptics.conf

if [ -e $i3_source ]; then
	echo Copying $i3_source to $i3_dest
	cp $i3_source $i3_dest
else
	echo !! Error copying $i3_source to $i3_dest !!
fi

if [ -e $sway_source ]; then
	echo Copying $sway_source to $sway_dest
	cp $sway_source $sway_dest
else
	echo !! Error copying $sway_source to $sway_dest !!
fi

if [ -e $bashp_source ]; then
	echo Copying $bashp_source to $bashp_dest
	cp $bashp_source $bashp_dest
else
	echo !! Error copying $bashp_source to $bashp_dest !!
fi

if [ -e $xres_source ]; then
	echo Copying $xres_source to $xres_dest
	cp $xres_source $xres_dest
else
	echo !! Error copying $xres_source to $xres_dest !!
fi

if [ -e $xtouchpad_source ]; then
	echo Copying $xtouchpad_source to $xtouchpad_dest
	cp $xtouchpad_source $xtouchpad_dest
else
	echo !! Error copying $xtouchpad_source to $xtouchpad_dest !!
fi

exit 0
