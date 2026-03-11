#!/usr/bin/env bash

# ffplay is a simple bash script music player tailor
# made for termux.

# refer for ffplay -h or the REAEME.TXT file
# for more info

# written by FELSNER Felipe in 2026
# kijetesantakalu li pona a

rm /data/data/com.termux/files/usr/bin/ffplay

read -p "remove depedencies, YES or NO? (shc,mpv,dialog)" CHOICE

if [ "$CHOICE" = "YES" ]||[ "$CHOICE" = "yes" ]||[ "$CHOICE" = "y" ];then
	pkg uninstall shc mpv dialog zip unzip
else 
	if [ CHOICE = "NO" ]||[ CHOICE = "no" ]||[ CHOICE = "n" ];then
		:
	fi
fi
