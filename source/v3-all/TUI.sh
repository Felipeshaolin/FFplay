#!/bin/bash

#https://tintin.mudhalla.net/info/xterm/

############
# defaults #
############

###colors
#modify as you wish (;

#default color values
red="\e[31m"
blue="\e[34m"
green="\e[32m"
violet="\e[345m"
yellow="\e[33m"
black="\e[30m"
white="\e[37m"
whiteblackbackground="\e[30m\e[47m"
stopcolor="\e[0m"

#borders
borderscolor=$blue
bottombarcolor=$borderscolor
topbarcolor=$borderscolor
leftbarcolor=$borderscolor
rightbarcolor=$borderscolor
logocolor=$green

#items
selecteditemcolor=$whiteblackbackground
itemcolor=$white
emptyitemcolor=$black

#buttons
buttoncolor=$white
buttonbordercolor=$white

playcolor=$green
playbordercolor=$green

shufflecolor=$violet
shufflebordercolor=$violet

quitcolor=$red
quitbordercolor=$red

###input

#quit,play,shouffle buttons
buttonclicked=0 #general button clickes
playbuttonclicked=0
shufflebuttonclicked=0
quitbuttonclicked=0


#mouse wheel
scrollup=0
scrolldown=0
#mouse coordinates
clickx=0
clicky=0

###terminal

out='/dev/tty' #for outputing truh cerr not cout
in='/dev/tty' #for inputing truh cerr not cout

#ṭerminal size
termsizex=30
termsizey=30

###menu

#labels for the buttons (one character long)
playlabel="▶"
shufflelabel="⇄"
quitlabel="x"

#numbers of buttons (can be changed if you want to add addtional buttons)
numberofbuttons=3
#size of interior of buttons
buttonsize=0
#currently chosen items
itemoffset=0
#padding for bottom buttons
bottompadding=10
#available size for text
sizefortext=26
#available size for items
availableslots=10
#top line of TUI
topline="╭──────────FFplay──────────╮"
#bottom line of TUI
bottomline="╰──────────────────────────╯"
#an array with all the item's names in it
declare -a itemtable;
#current items on display
declare -a curritems;

#############
# functions #
#############

###helper 

#updates the terminal size variables
function gettermsize(){

	#get and store values
	termsizex=$(tput cols)
	termsizey=$(tput lines)

	#check if minimum requirements are met
	if [[ $termsizex -le 8 && $termsizey -le 4 ]];then
		#your term is too small
		echo "${red}terminal size too small${stopcolor}" '$out'
		sleep 4
	fi	
}

#creates the top line
function printtopline(){

	# add X symbol
	topline="${red}X${stopcolor}"
	
	#add bars
	topline+=$topbarcolor
	for (( i = 0; i < $(( termsizex/2 - 4 )); i++ ))do
		topline+="─"
	done	

	#add logo
	topline+="${stopcolor}${logocolor}FFplay${topbarcolor}"
	
	#add bars
	for (( i = 0; i < $(( termsizex/2 - 4 )); i++ ))do
			topline+="─"
	done

	# add corner
	topline+="╮${stopcolor}"

	#display
	echo -e "$topline" > "$out"
}

#creates the top line
function printbottomline(){

	# add corner
	bottomline="${bottombarcolor}╰"
	
	#add lines
	for (( i = 0; i < $(( termsizex - 2 )); i++ ))do
		bottomline+="─"
	done

	# add another corner
	bottomline+="╯${stopcolor}"
	
	#display
	echo -en "$bottomline" > "$out"
}

#gets the available area for text
function getusabletextarea(){
	sizefortext=$((termsizex - 2))
	availableslots=$((termsizey - bottompadding))
}

#prints an item to the menu
# takes a string as argument
# takes a color as second argument
function printitem(){

	# the current item string
	local item="$1"
	local color="$2"

	# if the size of the string is too big...
	if [ ${#1} -gt $sizefortext ];then
		# clip it to size
		item="${item:0:${sizefortext}}${stopcolor}"
	fi

	# if the string is too small...
	if [ ${#1} -lt $sizefortext ];then

		# we add characters to it
		local sizeitem=${#item}
		for ((i=0;i<$(( sizefortext - sizeitem )); i++ ));do
			item+="${stopcolor}${emptyitemcolor}~${stopcolor}"
		done
	fi

	#display leftbar
	echo -en "${leftbarcolor}┃${stopcolor}" > "$out"
	#display item
	echo -en "${color}$item" > "$out"
	#display rightbar
	echo -en "${rightbarcolor}┃${stopcolor}\n" > "$out"
}

#prints the whole menu section
function printmenu(){

	curritems=() # list of items that will be siplayed

	# if there are too many items to display...
	if [ "$availableslots" -lt $(( ${#itemtable[@]} - itemoffset )) ]; then

		for (( i=itemoffset; i<$((availableslots + itemoffset)); i++ )); do
        	curritems+=("${itemtable[i]}")
    	done
	    availableslots=0   # mark that all slots are used

	else # the number of lines is suffcient
		
		# add all items from index onward
		for (( i=itemoffset ; i<${#itemtable[@]}; i++ ));do
			#add all items to the list
			availableslots=$(( availableslots -	1 ))
			curritems+=("${itemtable[i]}")

		done
	fi

	#display list of items
	for i in $(seq 0 ${#curritems[@]}); do
		local var
		var=${curritems[i]}

		if [ "$i" -eq 0 ];then
			printitem "$var" "$whiteblackbackground"
		else
    		printitem "$var" "$itemcolor"
		fi

	done	

	#display empty spaces if needed
	for i in $(seq 0 $availableslots);do
		printitem "" "$black"
	done

}

#prinsts the top of the buttons
function printtopbuttons(){

	local middlepoint=$(( termsizex  / numberofbuttons )) 

	#echo "$middlepoint"="$termsizex""/""$numberofbuttons"

	#play button
	local topbutton="${playbordercolor}╔"
	for i in $(seq 0 $((middlepoint - 3)) );do
		topbutton+="═"
	done
	topbutton+="╗${stopcolor}"

	#shuffle button
	topbutton+="${shufflebordercolor}╔"
	for i in $(seq 0 $((middlepoint - 3)) );do
		topbutton+="═"
	done
	topbutton+="╗${stopcolor}"

	#quit button
	topbutton+="${quitbordercolor}╔"
	for i in $(seq 0 $((middlepoint - 3)) );do
		topbutton+="═"
	done
	topbutton+="╗${stopcolor}\n"

	echo -ne "$topbutton" > "$out"

}

#prints the actual buttons decorations
function printbuttons(){

	local middlepoint=$(( termsizex  / numberofbuttons )) 

	#play button
	local button+="${playcolor}║"
	for i2 in $(seq 0 $((middlepoint - 3)) );do
		#print label
		if [ "$i2" -eq $(((middlepoint - 3)/2)) ];then
			button+="$playlabel"
		else
			button="${button} "
		fi
	done
	button+="║${stopcolor}"

	#shuffle button
	button+="${shufflecolor}║"
	for i2 in $(seq 0 $((middlepoint - 3)) );do

		#print label
		if [ "$i2" -eq $(((middlepoint - 3)/2)) ];then
			button+="$shufflelabel"
		else
			button="${button} "
		fi
	done
	button+="║${stopcolor}"

	#quit button
	button+="${quitcolor}║"
	for i2 in $(seq 0 $((middlepoint - 3)) );do
		#print label
		if [ "$i2" -eq $(((middlepoint - 3)/2)) ];then
			button+="$quitlabel"
		else
			button="${button} "
		fi
	done
	button+="║${stopcolor}\n"

	echo -ne "$button" > "$out"
}

#prints the bottom of the buttons
function printbottombuttons(){

	local middlepoint=$(( termsizex  / numberofbuttons )) 

	#echo "$middlepoint"="$termsizex""/""$numberofbuttons"

	#play button
	local bottombutton="${playbordercolor}╚"
	for i in $(seq 0 $((middlepoint - 3)) );do
		bottombutton+="═"
	done
	bottombutton+="╝${stopcolor}"

	#shuffle button
	bottombutton+="${shufflebordercolor}╚"
	for i in $(seq 0 $((middlepoint - 3)) );do
		bottombutton+="═"
	done
	bottombutton+="╝${stopcolor}"

	#quit button
	bottombutton+="${quitbordercolor}╚"
	for i in $(seq 0 $((middlepoint - 3)) );do
		bottombutton+="═"
	done
	bottombutton+="╝${stopcolor}"

	echo -ne "$bottombutton" > "$out"

}

###input

# pids=()
# program1 & pids+=($!)
# program2 & pids+=($!)
# program3 & pids+=($!)
# kill "${pids[@]}"

# (
#   # This is a subshell
#   program1 &
#   program2 &
#   wait
# ) &
# subshell_pid=$!


#this function monitors inputs and updates things like clicks
# and scrolls
function inputupdate(){

	echo -en '\e[?1000h' > "$out"  # basic mouse tracking
	echo -en '\e[?1006h' > "$out"  # enable SGR extended mode (easier coordinates)

	IFS= read -rsn1 -t 0.01 first  # read first byte

	# if its a code...
	if [[ $first == $'\e' ]]; then

	    read -rsn2 -t 0.01  rest
	    read -rsn20 -t 0.01 seq   # read remaining bytes

	    local full_seq="$first$rest$seq"
		local k 
	    k=$(printf '%q\n' "$full_seq") # get the code in a variable

	    inputupdatehelper "$k" # run helper

	fi

	#read additional trash data
	read -rs -t 0.01
	
} # helper for inputupdate function
function inputupdatehelper(){

	local prompt=$1	
 
	#scroll up
 	if [ "${prompt:6:2}" == '65' ] && [ $scrollup -ne 1 ];then

		scrollup=1

	#scroll down
 	elif [ "${prompt:6:2}" == '64' ] && [ $scrollup -ne 1 ];then
 	
 		scrolldown=1

	#clicks
 	elif [[ "${prompt:6:2}" == '0;' ]];then
 	 	
				#get coordinate section
 	 			local numbers="${prompt:7:9}" 
 	 			#clean the end
 	 			local numbers=${numbers%%[Mm]*}
 	 			#clean the start
 	 			local coords=${numbers#;}
				#there you go, some fresh coords, frsh out of the ainsi oven

				clickx=${coords%;*}
				clicky=${coords#*;}


	else
		# reset values if nothing is done
		#FIXME: probably broken...
		scrolldown=0
		scrollup=0

	fi

}

#updates scroll bool variables
function updatescroll(){

	#if scrolling downwards...
	if [ $scrolldown -eq 1 ];then
		itemoffset=$((itemoffset - 1 ))

	#if scrilling upwards...
	elif [ $scrollup -eq 1 ];then
		itemoffset=$((itemoffset + 1 ))

	fi

	#if the item offset is bigger than the number of items...
	if [ $itemoffset -ge ${#itemtable[@]} ];then
		itemoffset=$((${#itemtable[@]} - 1))
	fi 

	# if the item offset is negative...
	if [ $itemoffset -lt 0 ];then
		itemoffset=0
	fi
}

function checkbuttons(){

	#exit
	if [ "$clickx" -eq 1 ] && [ "$clicky" -eq 1 ];then # up-left red button
		closegracifully 1
	fi

	#shuffle
	if [ "$clickx" -gt $(( termsizex  / numberofbuttons )) ] && [ "$clickx" -lt $(( termsizex * 2 / numberofbuttons )) ] && [ "$clicky" -gt "$availableslots" ];then
		closegracifully 3
	fi

	#play
	if [ "$clickx" -lt $(( termsizex  / numberofbuttons )) ] && [ "$clicky" -gt "$availableslots" ];then
		closegracifully 2
	fi

	if [ "$clickx" -gt $(( termsizex * 2 / numberofbuttons )) ] && [ "$clicky" -gt "$availableslots" ];then 
		closegracifully 1
	fi

}

function closegracifully(){

	echo -en '\e[?1006l' > "$out"   # disable SGR extended mode
	echo -en '\e[?1000l' > "$out"  # disable basic mouse tracking
	stty echo > "$out" # make input visible
	clear > "$out" # clear terminal
	reset < "$in" > "$out" # reset just in case
	echo "output=""$itemoffset" 
	exit "$1" # close

}



###main

#main function, takes in the strings to display
function main_tui(){

	itemtable=()
	
	for i in $( seq 1 $# );do
		itemtable+=("${!i}")
	done
	
	echo -en "\e[?25l" > "$out" # clear screen
	stty -echo > "$out" # make input invisible

	#test
	while true;do

		#clears screen and puts cursor at 1,1
		tput home > "$out"

		#update values

		gettermsize # updates term sizes
		getusabletextarea # gets necessary area
		inputupdate # gets input
		updatescroll # treats input

		#prints menu
		printtopline
		printmenu
		printbottomline

		#prints buttons
		printtopbuttons
		printbuttons
		printbottombuttons

		# needed for error correction
		# FIXME:
		scrolldown=0
		scrollup=0

		checkbuttons

		#jan pi tomo suli li wile moku. ona li lukin e waso lon sewi. waso li toki: 'sina wile moku anu seme?' jan li toki: 'mi wile moku.' waso li awen, li pana e kili. jan li pilin pona."
		
	done

}