#!/bin/bash

#https://tintin.mudhalla.net/info/xterm/

############
# defaults #
############

###colors
#modify as you wish

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

###fucntion pid's
pids=()

###input

scrollup=0
scrolldown=0
#mouse coordinates
clickx=0
clicky=0

###terminal

#ṭerminal size
termsizex=30
termsizey=30

###menu

#currently chosen items
itemoffset=0
#padding for bottom buttons
bottompadding=3
#available size for text
sizefortext=26
#available size for items
availableslots=3
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

###main
function main_tui(){
	while true;do
		::
	done
}


###helper 

#updates the terminal size variables
function gettermsize(){

	#get and store values
	termsizex=$(tput cols)
	termsizey=$(tput lines)

	#check if minimum requirements are met
	if [[ $termsizex -le 8 && $termsizey -le 4 ]];then
		#your term is too small
		echo "${red}terminal size too small${stopcolor}"
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
	echo -e "$topline"
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
	echo -en "$bottomline"
}

#gets the available area for text
function getusabletextarea(){
	sizefortext=$((termsizex - bottompadding))
	availableslots=$((termsizey - 3))
	#echo "sizefortext=" $sizefortext
	#echo "available=" $availableslots

}

#prints an item to the menu
function printitem(){

	# if there arent any available slots...
	if [ $availableslots -le 0 ];then
		exit 0
		#do nothing
	fi
	
	# the current item string
	local item="$1"

	# if the size of the string is too big...
	if [ ${#1} -gt $sizefortext ];then
		# clip it to size
		item="${itemcolor}${item:0:${sizefortext}}${stopcolor}"
	fi

	# if the string is too small...
	if [ ${#1} -lt $sizefortext ];then

		# we add characters to it
		local sizeitem=${#item}
		for ((i=0;i<$(( sizefortext - sizeitem )); i++ ));do
			item+="${emptyitemcolor}~${stopcolor}"
		done

	fi

	#display leftbar
	echo -en "${leftbarcolor}┃${stopcolor}"
	#display item
	echo -en "$item"
	#display rightbar
	echo -e "${rightbarcolor}┃${stopcolor}"
}

#prints the whole menu section
function printmenu(){

	curritems=() # list of items that will be siplayed

	# if there are too many items to display...
	if [ $availableslots -lt $(( ${#itemtable[@]} - itemoffset )) ];then

		for (( i=0; i<availableslots; i++ ));do
			#add only items from the offset onwards till the size of availables slots
			curritems+=("${itemtable[ $(( i + itemoffset )) ]}")	
			availableslots=0

		done		
	
	else # the number of lines is suffcient
		
		# add all items from index onward
		for (( i=itemoffset ; i<${#itemtable[@]}; i++ ));do
			#add all items to the list
			availableslots=$(( availableslots -	1 ))
			curritems+=("${itemtable[i]}")

		done
	fi

	#display list of items
	for item in "${curritems[@]}";do
		printitem "$item"
	done	

	#display empty spaces if needed
	for i in $(seq 0 $availableslots);do
		printitem "~"
	done

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

	(echo -en '\e[?1000h')  # basic mouse tracking
	(echo -en '\e[?1006h')  # enable SGR extended mode (easier coordinates)

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


itemtable=("smells like teen spirit" "come as you are" "buddy holly" "lon poka mi" "7/8" "jojo op 3" "jan pi tomo suli li wile moku. ona li lukin e waso lon sewi. waso li toki: sina wile moku anu seme? jan li toki: mi wile moku. waso li awen, li pana e kili. jan li pilin pona.") # TODO: remove this, this is test material
echo -en "\e[?25l" # clear screen
stty -echo # make input invisible

#test
while true;do

	#clears screen and puts cursor at 1,1
	tput home

	#update values

	gettermsize # updates term sizes
	getusabletextarea # gets necessary area
	inputupdate # gets input
	updatescroll # treats input

	#prints menu
	printtopline
	printmenu
	printbottomline

	# needed for error correction
	# FIXME:
	scrolldown=0
	scrollup=0

	# if the uses clicks at 1,1 (little red X )...
	if [ "$clickx" -eq 1 ] && [ "$clicky" -eq 1 ];then
		echo -en '\e[?1006l'  # disable SGR extended mode
		echo -en '\e[?1000l'  # disable basic mouse tracking
		stty echo # make input visible
		clear # clear terminal
		reset # reset just in case
		break # end program execution
	fi

	#jan pi tomo suli li wile moku. ona li lukin e waso lon sewi. waso li toki: 'sina wile moku anu seme?' jan li toki: 'mi wile moku.' waso li awen, li pana e kili. jan li pilin pona."
	
done

