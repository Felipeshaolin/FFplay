#!/bin/bash

#https://tintin.mudhalla.net/info/xterm/

##defaults
#input
scrollup=0
scrolldown=0
clickx=0
clicky=0
#terminal
termsizex=0
termsizey=0
#menu
sizefortext=26
availableslots=3
topline="╭──────────FFplay──────────╮"
bottomline="╰──────────────────────────╯"
declare -a itemtable;
declare -a curritems;


##functions

#main
function main_tui(){
	while true;do
		::
	done
}


#helper

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
	echo -e $bottomline
}

#gets the available area for text
function getusabletextarea(){
	sizefortext=$((termsizex - 2))
	availableslots=$((termsizey-2))
}

#prints an tiem to the menu
function printitem(){

	if [ $availableslots -eq 0 ];then
		exit 1
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
	echo -en "┃"
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
			availableslots=$(( availableslots -	${#itemtable[@]} ))
			curritems+=("$item")
		done
	fi

	for item in "${curritems[@]}";do
		printitem "$item"
	done	

	for i in $(seq 0 $availableslots);do
		printitem "-"
	done

}

##input

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

	echo -e '\e[?1000h'  # basic mouse tracking
	echo -e '\e[?1006h'  # enable SGR extended mode (easier coordinates)
	while true;do
	IFS= read -rsn1 first  # read first byte
	if [[ $first == $'\e' ]]; then
	    read -rsn2 rest
	    read -rsn20 seq   # read remaining bytes (adjust length if needed)
	    local full_seq="$first$rest$seq"
		local k 
	    k=$(printf '%q\n' "$full_seq")
	    inputupdatehelper "$k"
	    #echo $k
	fi
	done
	
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
	
			#echo $prompt
			::
	 	 			
	 	fi
	
}

#test
while true;do

	clear

	itemtable=("dance like jagger" "lon poka mi" "plastic beach")
	
	#update values
	gettermsize
	getusabletextarea

	printtopline
	printmenu
	printbottomline

	echo "availableslots="$availableslots

	#jan pi tomo suli li wile moku. ona li lukin e waso lon sewi. waso li toki: 'sina wile moku anu seme?' jan li toki: 'mi wile moku.' waso li awen, li pana e kili. jan li pona."
	sleep 0.6
	
done
