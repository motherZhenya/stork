#!/bin/bash
#   + ----------------------------- +
#   |   STORK Interface Settings    |
#   |   Author: Nikolay Andriyshuk  |
#   |   Email: <nikoniik@chita.ru>      |
#   |   Version: 1.0                |
#   |   License: GPL 3              |
#   + ----------------------------- +
#
# x_panel_refresh
# поиск изображений панели 
# Найти Фоновое Изображение панели или использовать системный стиль
export PANELLI=`xfconf-query -c xsettings -p /Net/ThemeName -v`

FILEE="/usr/share/themes/${PANELLI}/gtk-2.0/Panel/panel-bg.png"
Filee="/usr/share/themes/${PANELLI}/gtk-2.0/panel/panel-bg.png"
FILES="${HOME}/.themes/${PANELLI}/gtk-2.0/Panel/panel-bg.png"
Files="${HOME}/.themes/${PANELLI}/gtk-2.0/panel/panel-bg.png"

echo "xfconf-query -c xfce4-panel -p /panels/panel-1/background-style --set "0"" > /tmp/PANELT
[ ! -e "${FILEE}" ] || echo -e "\n xfconf-query -c xfce4-panel -p /panels/panel-1/background-style --set "2"\n xfconf-query -c xfce4-panel -p /panels/panel-1/background-image --set ${FILEE}" > /tmp/PANELT
[ ! -e "${Filee}" ] || echo -e "\n xfconf-query -c xfce4-panel -p /panels/panel-1/background-style --set "2"\n xfconf-query -c xfce4-panel -p /panels/panel-1/background-image --set  ${Filee}" > /tmp/PANELT
[ ! -e "${FILES}" ] || echo -e "\n xfconf-query -c xfce4-panel -p /panels/panel-1/background-style --set "2"\n xfconf-query -c xfce4-panel -p /panels/panel-1/background-image --set  ${FILES}" > /tmp/PANELT
[ ! -e "${Files}" ] || echo -e "\n xfconf-query -c xfce4-panel -p /panels/panel-1/background-style --set "2"\n xfconf-query -c xfce4-panel -p /panels/panel-1/background-image --set  ${Files}" > /tmp/PANELT 

sh -s < /tmp/PANELT
wait

# Определить Размер Фонового Изображения панели
file "`xfconf-query -c xfce4-panel -p /panels/panel-1/background-image -v`" > /tmp/PANneL # Извлечь аттрибуты файла
cut -d ',' -f 2 /tmp/PANneL | cut -c 6-8 > /tmp/PANneLsize # считать высоту изображения
read -r PANELISIZE < /tmp/PANneLsize # Присвоим переменную
grep -q "/panel-bg.png" /tmp/PANELT && xfconf-query --channel 'xfce4-panel' --property '/panels/panel-1/size' --create --type int --set ${PANELISIZE}
xfce4-panel -r # Рестарт панели
wait
#
#
# ОСНОВА
res1=$(mktemp --tmpdir iface1.XXXXXXXX)

gc_file="${XDG_CONFIG_HOME:-$HOME/.config}/Gtk3Theme"

kc_file="${XDG_CONFIG_HOME:-$HOME/.config}/return"

rc_file="${XDG_CONFIG_HOME:-$HOME/.config}/index.theme"

# разбор rc файлов
PARSER='
BEGIN { FS="="; OFS="\n"; }
/^GtkTheme/ {printf "GTKTHEME=%s\n", $2}
/^Xfwm4Theme/ {printf "XFWM4THEME=%s\n", $2}
/^MetacityTheme/ {printf "METACITYTHEME=%s\n", $2}
/^Gtk3Theme/ {printf "GTK3THEME=%s\n", $2}
/^IconTheme/ {printf "ICONTHEME=%s\n", $2}
/^CursorTheme/ {printf "CURSORTHEME=%s\n", $2}
/^ButtonLayout/ {printf "BUTONLAYOUT=%s\n", $2}
'
eval $(sed -r "s/[ \t]*=[ \t]*/=/" $rc_file | awk "$PARSER")

# создать список: gtk-2.0; -3.0; theme XFWM4 theme;  metacity theme;
GtkThemelist="Default"
xfwm4themelist="Default"
metacitythemelist="Default"
Gtk3themelist="Default"
for d in /usr/share/themes/* $HOME/.themes/*; do
    theme=${d##*/}
    if [[ -e $d/gtk-2.0/gtkrc ]]; then
        [[ $GtkThemelist ]] && GtkThemelist="$GtkThemelist!"
        [[ $theme == $GTKTHEME ]] && theme="^$theme"
        GtkThemelist+="$theme"
    fi
    if [[ -e $d/xfwm4/themerc ]]; then
        [[ $theme == $XFWM4THEME ]] && theme="^$theme"
        xfwm4themelist+="!$theme"
    fi
    if [[ -e $d/metacity-1/metacity-theme-1.xml ]]; then
        [[ $theme == $METACITYTHEME ]] && theme="^$theme"
        metacitythemelist+="!$theme"
    fi
    if [[ -e $d/gtk-3.0/gtk.css ]]; then
        [[ $theme == $GTK3THEME ]] && theme="^$theme"
        Gtk3themelist+="!$theme"
    fi
done

# Создать список тем иконок и курсора:            

IconThemelist="Default"
cursorthemelist="Default"
for d in /usr/share/icons/* $HOME/.icons/*; do
    theme=${d##*/}
    if [[ -e $d/icon-theme.cache ]]; then
        [[ $theme == $ICONTHEME ]] && theme="^$theme"
        IconThemelist+="!$theme"
    fi
    if [[ -e $d/cursors ]]; then
        [[ $theme == $CURSORTHEME ]] && theme="^$theme"
        cursorthemelist+="!$theme"
    fi
done

# Create list of ButtonLayout;
ButtonLayoutlist=""
[[ $BUTONLAYOUT == menu:minimize,maximize,close ]] && ButtonLayoutlist+="^"
ButtonLayoutlist+="O|HMC"!
[[ $BUTONLAYOUT == close,maximize,minimize:menu ]] && ButtonLayoutlist+="^"
ButtonLayoutlist+="CMH|O"!
[[ $BUTONLAYOUT == menu:maximize,minimize,close ]] && ButtonLayoutlist+="^"
ButtonLayoutlist+="O|MHC"!
[[ $BUTONLAYOUT == close,minimize,maximize:menu ]] && ButtonLayoutlist+="^"
ButtonLayoutlist+="CHM|O"!

yad --window-icon=/opt/stork/theme_custom/icon/Star.png --title="Interface settings" --image-on-top \
    --image=/opt/stork/theme_custom/icon/logocustom260.png \
    --form --separator='\n' --quoted-output \
    --form --field="gtk-2.0 theme::cb" "$GtkThemelist" \
    --form --field="Xfwm4 theme::cb" "$xfwm4themelist" \
    --form --field="Metacity theme::cb" "$metacitythemelist" \
    --form --field="Gtk 3.0 theme::cb" "$Gtk3themelist" \
    --form --field="Icons theme::cb" "$IconThemelist" \
    --form --field="Cursor theme::cb" "$cursorthemelist" \
    --field="Button Layout::cb" "$ButtonLayoutlist" > $res1 \
    --field="WM":fbtn "mintdesktop exit 1"

# recreate rc file
if [[ $? -eq 0 ]]; then
    eval TAB1=($(< $res1))

    echo -e "\n# This file was generated automatically\n" > $rc_file
    echo -e "\n#!/bin/bash\n sleep 1" > $kc_file

    echo "GtkTheme=\"${TAB1[0]}\"" >> $rc_file
    [[ ${TAB1[1]} != Default ]] && echo "Xfwm4Theme=\"${TAB1[1]}\"" >> $rc_file
    [[ ${TAB1[2]} != Default ]] && echo "MetacityTheme='${TAB1[2]}'" >> $rc_file
    [[ ${TAB1[3]} != Default ]] && echo "Gtk3Theme=\"${TAB1[3]}\"" >> $rc_file | [[ ${TAB1[3]} != Default ]] && echo "${TAB1[3]}" > $gc_file
    [[ ${TAB1[4]} != Default ]] && echo "IconTheme=\"${TAB1[4]}\"" >> $rc_file
    [[ ${TAB1[5]} != Default ]] && echo "CursorTheme=\"${TAB1[5]}\"" >> $rc_file
    echo >> $rc_file

    echo -e "xfconf-query -c xsettings -p /Net/ThemeName -s \"${TAB1[0]}\"" >> $kc_file
    echo -e "xfconf-query -c xfwm4 -p /general/theme -s \"${TAB1[1]}\"" >> $kc_file
    echo -e "gsettings set org.gnome.metacity theme '${TAB1[2]}'" >> $kc_file
    echo -e "xfconf-query -c xsettings -p /Net/IconThemeName -s \"${TAB1[4]}\"" >> $kc_file
    echo -e "xfconf-query -c xsettings -p /Gtk/CursorThemeName -s \"${TAB1[5]}\"" >> $kc_file
    echo >> $kc_file

      if [[ ${TAB1[6]} != $"None" ]]; then
        case ${TAB1[6]} in
            "O|HMC") echo "ButtonLayout = 'menu:minimize,maximize,close'" >> $rc_file | echo -e "\ngsettings set org.gnome.desktop.wm.preferences button-layout 'menu:minimize,maximize,close'\nxfconf-query -c xfwm4 -p /general/button_layout -s \"OS|HMC\"" >> $kc_file ;;
            "CMH|O") echo "ButtonLayout = 'close,maximize,minimize:menu'" >> $rc_file | echo -e "\ngsettings set org.gnome.desktop.wm.preferences button-layout 'close,maximize,minimize:menu'\nxfconf-query -c xfwm4 -p /general/button_layout -s \"CMH|SO\"" >> $kc_file ;;
            "O|MHC") echo "ButtonLayout = 'menu:maximize,minimize,close'" >> $rc_file | echo -e "\ngsettings set org.gnome.desktop.wm.preferences button-layout 'menu:maximize,minimize,close'\nxfconf-query -c xfwm4 -p /general/button_layout -s \"OS|MHC\"" >> $kc_file ;;
            "CHM|O") echo "ButtonLayout = 'close,minimize,maximize:menu'" >> $rc_file | echo -e "\ngsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:menu'\nxfconf-query -c xfwm4 -p /general/button_layout -s \"CHM|SO\"" >> $kc_file ;;
        esac
      fi

    echo -e "\n xfconf-query -c xfwm4 -p /general/workspace_count -s \"4\" \n" >> $kc_file
    echo >> $kc_file
    #echo -e "\nxthemeread &&" >> $kc_file
    echo -e "\n/usr/local/bin/gtk3th.sh &&\n sleep 1" >> $kc_file
    echo -e "\nxthemeread\nexit 0" >> $kc_file
    wait
    cd $HOME/.config/
    sh $HOME/.config/return
fi

# cleanup
rm -f $res1

exit 1
