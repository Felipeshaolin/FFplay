#!/data/data/com.termux/files/usr/bin/bash 

#/data/data/com.termux/files/usr/bin/bash

# ffplay is a simple bash script music player tailor
# made for termux.

# refer for ffplay -h or the README.TXT file
# for more info

# written by FELSNER Felipe in 2026
# kijetesantakalu li jan lawa

#version of script
VERSION=2

RANDOM_VAR=0

#depedency check
dialog
if [ $? -nq 0 ];then
	echo "error: dialog is not installed or is not in path"
	exit 1
fi
mpv
if [ $? -nq 0 ];then
	echo "error: mpv is not installed or is not in path"
	exit 1
fi



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

	mapfile -t TEMP_FILE_LIST < <(find -maxdepth 1 -type f)

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
for i in "${!TEMP_FILE_LIST[@]}"; do
	# FILE_LIST+=("$i" "${TEMP_FILE_LIST[$i]##*/}" )
	FILE_LIST+=("$i" "${TEMP_FILE_LIST[$i]}" )

done


#main loop

while [ 1 -eq 1 ]; do


	#temporary list for removing file extention
	#and full path
	TEMP_FILE_LIST=()
	
	index=0
	for i in "${!FILE_LIST[@]}"; do

		TEMP_FILE_LIST+=("${FILE_LIST[$i]##*/}")
		
	done
# 
# 		if [ $(($i % 2)) -eq 0 ]; then
# 			TEMP_FILE_LIST+="${FILE_LIST[$i]##*/}"
# 		else
# 			TEMP_FILE_LIST+="${FILE_LIST[$i]}"
# 		fi

	#good old dialog box
	#god how i hate dialog
	FILE_INDEX=$(dialog \
		--ok-label "Play" \
		--cancel-label "Quit" \
		--extra-button \
		--extra-label "shuffle" \
		--menu "Pick a file:" 20 70 10 \
		"${TEMP_FILE_LIST[@]}" \
		3>&1 1>&2 2>&3)

	#suffle feature
	if [ $? -eq 3 ]; then

		rng 0 $FILE_COUNT

		#rng
		FILE_INDEX=$RANDOM_VAR

		#playback
		clear
		mpv --terminal=yes "${FILE_LIST[$(( "$FILE_INDEX"*2 + 1 ))]}" 
		
	else
	
		#normal playback
		clear
		mpv --terminal=yes "${FILE_LIST[$(( "$FILE_INDEX"*2 + 1 ))]}"	

	fi
	
	#the cancel button
	if [ $? -eq 1 ];then
		clear
		break
	fi

	clear # clears the screen of mpv's echoes

done

reset # resets the terminal, otherwise errors may accour

if [ -d "$TEMP" ];then
	rm -r "$TEMP""/"
fi

#remove temp dialog config file
rm -f "$DIALOGRC_FILE"

exit 0
