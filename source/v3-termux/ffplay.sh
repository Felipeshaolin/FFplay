#!/data/data/com.termux/files/usr/bin/bash

# ffplay is a simple bash script music player

# refer for ffplay -h or the README.TXT file
# for more info

# written by FELSNER Felipe in 2026
# kijetesantakalu li jan lawa

# shellcheck disable=SC1091
source ./TUI.sh

#version of script
VERSION=3

RANDOM_VAR=0

bg_pid=""

#dialog config \/

DIALOGRC_FILE=$(mktemp)

#dialog's color options...
cat <<'EOF' > "$DIALOGRC_FILE"
screen_color = (BLACK,BLACK,ON)
shadow_color = (BLACK,BLACK,ON)
dialog_color = (BLACK,WHITE,OFF)
title_color = (BLACK,BLACK,ON)
border_color = (BLACK,BLACK,ON)
button_active_color = (BLACK,WHITE,ON)
button_inactive_color = dialog_color
button_key_active_color = button_active_color
button_key_inactive_color = (RED,WHITE,OFF)
button_label_active_color = (WHITE,BLACK,ON)
button_label_inactive_color = (BLACK,WHITE,ON)
inputbox_color = dialog_color
inputbox_border_color = dialog_color
searchbox_color = dialog_color
searchbox_title_color = (WHITE,BLACK,ON)
searchbox_border_color = border_color
position_indicator_color = (WHITE,BLACK,ON)
menubox_color = (BLACK,BLACK,ON)
menubox_border_color = (BLACK,BLACK,ON)
item_color = (WHITE,BLACK,ON)
item_selected_color = (BLACK,WHITE,ON)
tag_color = (WHITE,BLACK,ON)
tag_selected_color = button_label_active_color
tag_key_color = tag_color
tag_key_selected_color = (BLACK,WHITE,ON)
check_color = dialog_color
check_selected_color = button_active_color
uarrow_color = (GREEN,WHITE,ON)
darrow_color = uarrow_color
itemhelp_color = (WHITE,BLACK,ON)
form_active_text_color = (BLACK,WHITE,ON)
form_text_color = (WHITE,BLACK,ON) 
form_item_readonly_color = (CYAN,WHITE,ON) 
gauge_color = (BLACK,WHITE,ON) 
border2_color = (BLACK,BLACK,ON)
inputbox_border2_color = dialog_color
searchbox_border2_color = dialog_color
menubox_border2_color = (BLACK,BLACK,ON)
EOF

export DIALOGRC="$DIALOGRC_FILE"

LAST_SONG=0

#rng function
rng(){

	min=$1
	max=$2
	range=$((max - min + 1))

	limit=$((32768 / range * range))

	while :; do
		r=$RANDOM
	    if (( r < limit )); then
	  		RANDOM_VAR=$(( r % range + min ))
	 		break
	  	fi
	done
}


#help argument
if [ "$1" = "-h" ]; then
	echo -e "ffplay_v.0.$VERSION simple music player tui using mpv \nusage:ffplay -h [directory/zip file]"
	exit 0
fi 

#get the home directory for the music files
if [ $# -eq 0 ]; then

	mapfile -t TEMP_FILE_LIST < <(find . -maxdepth 1 -type f )

else

	if file "$1" | grep -q "Zip archive";then

		#create a simple temp file for the music files
		TEMP="TEMP_FFPLAY_DIR"
		mkdir "$TEMP"
		unzip -q "./$1" -d "$TEMP"

		#depht is 2 cause the zip may contain multiple folders
		mapfile -t TEMP_FILE_LIST < <(find "$TEMP" -maxdepth 3 -type f)
		
	else
	
		mapfile -t TEMP_FILE_LIST < <(find "$1" -maxdepth 1 -type f)

	fi
fi


#a number of the files that are available, used by shuffle
FILE_COUNT=${#TEMP_FILE_LIST[@]} 


#format the data in a more useble state
FILE_LIST=()
#for i in "${!TEMP_FILE_LIST[@]}"; do
#	# FILE_LIST+=("$i" "${TEMP_FILE_LIST[$i]##*/}" )
#	FILE_LIST+=("$i" "${TEMP_FILE_LIST[$i]}" )
#
#done


#main loop

DIALOG_RET=0 # the return value of dialog

while true; do

	#temporary list for removing file extention
	#and full path
	
	for i in "${!FILE_LIST[@]}"; do

		TEMP_FILE_LIST+=("${FILE_LIST[$i]##*/}")
		
	done
# 
# 		if [ $(($i % 2)) -eq 0 ]; then
# 			TEMP_FILE_LIST+="${FILE_LIST[$i]##*/}"
# 		else
# 			TEMP_FILE_LIST+="${FILE_LIST[$i]}"
# 		fi

	FILE_INDEX=$(main_tui "$LAST_SONG" "$DIALOG_RET" "${TEMP_FILE_LIST[@]}" </dev/tty )

	DIALOG_RET=$?

	echo $DIALOG_RET
	sleep 2

	FILE_INDEX=${FILE_INDEX##*output=}
	LAST_SONG=$FILE_INDEX

	#the cancel button
	if [ $DIALOG_RET -eq 1 ];then
		clear
		break
	fi

	#auto shuffle
	if [ $DIALOG_RET -eq 30 ] && [[ -n "$bg_pid" ]] && ! kill -0 "$bg_pid" 2>/dev/null;then 

		rng 0 "$FILE_COUNT"

		#rng
		FILE_INDEX=$RANDOM_VAR

		#playback
		mpv "${TEMP_FILE_LIST[$FILE_INDEX]}" >/dev/null 2>&1 &
		bg_pid=$!

	fi

	#auto play
	if [ $DIALOG_RET -eq 20 ] && [[ -n "$bg_pid" ]] && ! kill -0 "$bg_pid" 2>/dev/null;then 

		#normal playback
		echo "play"
		echo "${TEMP_FILE_LIST[$FILE_INDEX]}"
		sleep 3
		mpv "${TEMP_FILE_LIST[$FILE_INDEX]}" >/dev/null 2>&1 &
		bg_pid=$!

	fi

	#suffle feature
	if [ $DIALOG_RET -eq 3 ]; then

		rng 0 "$FILE_COUNT"

		#rng
		FILE_INDEX=$RANDOM_VAR

		#playback
		mpv "${TEMP_FILE_LIST[$FILE_INDEX]}" >/dev/null 2>&1 &
		bg_pid=$!
		
	else
	
		#normal playback
		mpv "${TEMP_FILE_LIST[$FILE_INDEX]}" >/dev/null 2>&1 &
		bg_pid=$!

	fi

	#read garbage data
	read -rs -t 0.01

done

reset # resets the terminal, otherwise errors may accour

if [ -d "$TEMP" ];then
	rm -r "${TEMP:?}""/"
fi

#remove temp dialog config file
rm -f "$DIALOGRC_FILE"

pkill mpv

exit 0
