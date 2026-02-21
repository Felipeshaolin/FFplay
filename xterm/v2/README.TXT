
	ffplay is a simple bash script music player tailor
made for termux.

installation:
	bash install.sh
	#this compiles the script and adds the binary to
	#/data/data/com.termux/files/usr/bin/, it also
	#installs dependencies using pkg:

	-mpv # for music playback
	-dialog # for the TUI
	-shc # the compiler

removal:
	bash uninstall.sh
	#this wi give you a prompt asking if you want to
	# remove package dependencies installed in the 
	# installation proccess.

basic usage:
	ffplay 
	# run the program, a dialog box with you current 
	# folder's content should appear, choose the music
	# you want to listen to. a mpv music player should
	# appear. refear to man mpv for usage information.

	or

	ffplay [directory]
	# ffplay will open on the directory you specified.

	or
	
	ffplay -h
	#displays simple info.

written by FELSNER Felipe in 2026
kijetesantakalu li tawa sike (;
