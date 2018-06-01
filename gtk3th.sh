#!/bin/bash
# x_ubuntu
# Портировал на YAD
# Nikolay Andriychuk <nikonik@chiita.ru>
#
# script to copy gtk-3.0 to ~/.config/
# by Mr Green & darktux
# gtk3switch version 0.2


# paths
user_home=/home/${USER}  
theme_name=$@ # all arguments....
theme_dir=${user_home}/.themes
system_theme_dir=/usr/share/themes

if [ $# -eq 0 ]; then  
        find ${system_theme_dir} ${theme_dir} -type d -name 'gtk-3.0' | awk -F'/' '{print $5}' > /tmp/themegtkplus
fi

read -r theme_name < $HOME/.config/Gtk3Theme

# Check if theme exists then copy it if it does
flag=0  
for x in $system_theme_dir $theme_dir; do  
    if [ -d ${x}/"${theme_name}"/gtk-3.0 ]; then
      cp -a ${x}/"${theme_name}"/gtk-3.0 ${user_home}/.config
      echo "Gtk3 theme ${theme_name} installed"
      flag=1
    fi
done

