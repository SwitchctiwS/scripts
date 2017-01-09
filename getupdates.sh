#!/bin/sh

i3_source=~/.config/i3/config
i3_dest=~/.dotfiles/arch/i3/config

sway_source=~/.config/sway/config
sway_dest=~/.dotfiles/arch/sway/config

bashp_source=~/.bash_profile
bashp_dest=~/.dotfiles/arch/.bash_profile

xres_source=~/.Xresources
xres_dest=~/.dotfiles/arch/.Xresources

echo copying $i3_source to $i3_dest
cp $i3_source $i3_dest
echo copying $sway_source to $sway_dest
cp $sway_source $sway_dest
echo copying $bashp_source to $bashp_dest
cp $bashp_source $bashp_dest
echo copying $xres_source to $xres_dest
cp $xres_source $xres_dest

exit 0
