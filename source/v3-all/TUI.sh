#!/bin/bash

#https://tintin.mudhalla.net/info/xterm/

############
# defaults #
############

###fucntion pid's
pids=()

###colors




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

	termsizex=$(tput cols)
	termsizey=$(tput lines)

	if [[ $termsizex -le 8 && $termsizey -le 4 ]];then
		#your term is too small
		echo "terminal size too small"
		sleep 4
	fi	
}

#creates the top line
function printtopline(){
	topline="╭"
	for (( i = 0; i < $(( termsizex/2 - 4 )); i++ ))do
		topline+="─"
	done	
	topline+="FFplay"
	for (( i = 0; i < $(( termsizex/2 - 4 )); i++ ))do
			topline+="─"
	done
	topline+="╮"

	echo -e $topline
}

#creates the top line
function printbottomline(){
	bottomline="╰"
	for (( i = 0; i < $(( termsizex - 2 )); i++ ))do
		bottomline+="─"
	done
	bottomline+="╯"
	echo -en $bottomline
}

#gets the available area for text
function getusabletextarea(){
	sizefortext=$((termsizex - bottompadding))
	availableslots=$((termsizey - 3))
	#echo "sizefortext=" $sizefortext
	#echo "available=" $availableslots

}

#prints an tiem to the menu
function printitem(){

	if [ $availableslots -le 0 ];then
		exit 0
	fi
	
	local item="$1"

	if [ ${#1} -gt $sizefortext ];then
		item=${item:0:${sizefortext}}
	fi

	if [ ${#1} -lt $sizefortext ];then

		local sizeitem=${#item}
		for ((i=0;i<$(( sizefortext - sizeitem )); i++ ));do
			item+="-"
		done

	fi

	echo -en "┃"
	echo -en "$item"
	echo -e "┃"
}

#prints the whole menu section
function printmenu(){

	curritems=()
	

	if [ $availableslots -lt ${#itemtable[@]} ];then
		for (( i=0; i<availableslots; i++ ));do
			curritems+=("${itemtable[${i}]}")	
			availableslots=0
		done		
	else
		for item in "${itemtable[@]}";do
			#echo "ici2" ${#itemtable[@]} ">" $availableslots
			availableslots=$(( availableslots -	1 ))
			curritems+=("$item")
		done
	fi

	#echo "${#itemtable[@]}"

	for item in "${curritems[@]}";do
		printitem "$item"
	done	

	for i in $(seq 0 $availableslots);do
		printitem "-"
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

#is is a function meant to be ran in the background
#it monitors inputs and updates things like clicks
# and scrolls
function inputupdate(){

	(echo -en '\e[?1000h')  # basic mouse tracking
	(echo -en '\e[?1006h')  # enable SGR extended mode (easier coordinates)
	IFS= read -rsn1 -t 0.01 first  # read first byte
	if [[ $first == $'\e' ]]; then
	    read -rsn2 -t 0.01  rest
	    read -rsn20 -t 0.01 seq   # read remaining bytes (adjust length if needed)
	    local full_seq="$first$rest$seq"
		local k 
	    k=$(printf '%q\n' "$full_seq") 
	    inputupdatehelper "$k" 
	fi
	
}
function inputupdatehelper(){

	local prompt=$1	
	 
	 	if [[ "${prompt:6:2}" == '65' ]];then
	
			scrollup=1
	
	 	elif [[ "${prompt:6:2}" == '64' ]];then
	 	
	 		scrolldown=1
	
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
	
			scrollup=0
			scrolldown=0
	 	 			
	 	fi
	
}



itemtable=("smells like teen spirit" "come as you are" "buddy holly" "lon poka mi" "7/8" "jojo op 3")
echo -en "\e[?25l"

#test
while true;do

	tput home

	#update values
	gettermsize
	getusabletextarea
	inputupdate

	#prints menu
	printtopline
	printmenu
	printbottomline

	if [ "$clickx" -eq 1 ] && [ "$clicky" -eq 1 ];then
		echo -en '\e[?1006l'  # disable SGR extended mode
		echo -en '\e[?1000l'  # disable basic mouse tracking
		#clear
		#reset
		break
	fi

	#jan pi tomo suli li wile moku. ona li lukin e waso lon sewi. waso li toki: 'sina wile moku anu seme?' jan li toki: 'mi wile moku.' waso li awen, li pana e kili. jan li pona."
	
done

