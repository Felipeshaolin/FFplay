#!/bin/bash

cat ffplay.sh TUI.sh > combined.sh
shc -f combined.sh -o ffplay
