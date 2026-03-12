 

##defaults
termsizex=0
termsizey=0
sizefortext=26
availableslots=3
topline="╭──────────FFplay──────────╮"
botline="╰──────────────────────────╯"



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
	for (( i = 0; i < $(( $termsizex/2 - 4 )); i++ ))do
		topline+="─"
	done	
	topline+="FFplay"
	for (( i = 0; i < $(( $termsizex/2 - 4 )); i++ ))do
			topline+="─"
	done
	topline+="╮"

	echo -e $topline
}

#gets the available area for text
function getusabletextarea(){
	sizefortext=$(($termsizex - 2))
	availableslots=$(($termsizey-2))
}

#prints an tiem to the menu
function printitem(){

	if [ $availableslots -eq 0 ];then
		exit 1
	fi
	
	item=$1

	if [ ${#1} -gt $(( $termsizex - 2 )) ];then
		item=$(cut -b 1-$(( $termsizex - 2 )) "$item" )
	fi

	echo -en "┃"
	echo -en $item
	echo -en "┃"
	
}

gettermsize
printtopline
printitem "hellomynameismeJJJJJJJJJJJJJJJJJJJJJJJJJJJJjJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ"
