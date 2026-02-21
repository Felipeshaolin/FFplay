#!/data/data/com.termux/files/usr/bin/bash
#/data/data/com.termux/files/usr/bin/bash

# ffplay is a simple bash script music player tailor
# made for termux.

# refer for ffplay -h or the README.TXT file
# for more info

# written by FELSNER Felipe in 2026
# kijetesantakalu li jan lawa

#version of script
VERSION=1

# DIALOGRC_FILE=$(mktemp)
# 
# #dialog's color options...
# */
# cat <<'EOF' > "$DIALOGRC_FILE"
# screen_color = (BLACK,BLACK,ON)
# shadow_color = (BLACK,BLACK,ON)
# dialog_color = (BLACK,WHITE,OFF)
# title_color = (BLACK,WHITE,ON)
# border_color = (BLACK,BLACK,ON)
# button_active_color = (WHITE,BLUE,ON)
# button_inactive_color = dialog_color
# button_key_active_color = button_active_color
# button_key_inactive_color = (RED,WHITE,OFF)
# button_label_active_color = (WHITE,BLACK,ON)
# button_label_inactive_color = (BLACK,WHITE,ON)
# inputbox_color = dialog_color
# inputbox_border_color = dialog_color
# searchbox_color = dialog_color
# searchbox_title_color = title_color
# searchbox_border_color = border_color
# position_indicator_color = title_color
# menubox_color = (BLACK,BLACK,ON)
# menubox_border_color = border_color
# item_color = dialog_color
# item_selected_color = button_active_color
# tag_color = (WHITE,BLACK,ON)
# tag_selected_color = button_label_active_color
# tag_key_color = tag_color
# tag_key_selected_color = (BLACK,WHITE,ON)
# check_color = dialog_color
# check_selected_color = button_active_color
# uarrow_color = (GREEN,WHITE,ON)
# darrow_color = uarrow_color
# itemhelp_color = (WHITE,BLACK,OFF)
# form_active_text_color = button_active_color
# form_text_color = (WHITE,CYAN,ON)
# form_item_readonly_color = (CYAN,WHITE,ON)
# gauge_color = (BLACK,WHITE,ON)
# border2_color = dialog_color
# inputbox_border2_color = dialog_color
# searchbox_border2_color = dialog_color
# menubox_border2_color = dialog_color
# EOF
# 
# export DIALOGRC="$DIALOGRC_FILE"

#help argument
if [ "$1" = "-h" ]; then
	echo -e "ffplay_v.0.$VERSION simple music player tui using mpv \nusage:ffplay -h [directory]"
	exit 0
fi 

#get the home directory for the music files
if [ $# -eq 0 ]; then
	mapfile -t TEMP_FILE_LIST < <(find -maxdepth 1 -type f)
else
	mapfile -t TEMP_FILE_LIST < <(find "$1" -maxdepth 1 -type f)
fi


#format the data in a more useble state
FILE_LIST=()
for i in "${!TEMP_FILE_LIST[@]}"; do
	FILE_LIST+=("$i" "${TEMP_FILE_LIST[$i]}" )
done


while [ 1 -eq 1 ]; do

	#good old dialog box
	#god how i hate dialog
	FILE_INDEX=$(dialog --menu "Pick a file:" 20 70 10 \
		"${FILE_LIST[@]}" \
		3>&1 1>&2 2>&3)
		
	#the cancel button
	if [ $? -gt 0 ];then
		clear
		exit 0
	fi

	clear 
	mpv "${FILE_LIST[$(( "$FILE_INDEX"*2 + 1 ))]}"
	clear

done

reset

# rm -f "$DIALOGRC_FILE"
	
