#!/bin/bash

cat TUI.sh ffplay.sh > combined.sh
shc -f combined.sh -o ffplay
mv ffplay /data/data/com.termux/files/usr/bin/
