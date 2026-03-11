#!/usr/bin/env bash

# ffplay is a simple bash script music player tailor
# made for termux.

# refer for ffplay -h or the README.TXT file
# for more info

# written by FELSNER Felipe in 2026
# kijetesantakalu li jan sewi

pkg install dialog mpv shc zip unzip
shc -f ffplay.sh -o ffplay
mv ffplay /data/data/com.termux/files/usr/bin/
rm ffplay.sh.x.c
