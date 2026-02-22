# FFplay

	a simple free and open source music player for linux and termux. 

## dependencies

- mpv : for music playback
- dialog : for the tui
- zip/unzip : for reading zip files containing music files

### optional

- shc : for compilation only (not necessary if ran directly)


## instalation

### direct running
as FFplay is a bash script application it can be ran from any terminal (as long as the dependencies are installed).
to do so use **"bash"**, ***not "sh" as it does not support the features used by FFplay!***
run:\
'''git clone '''\
'''cd FFplay'''\
'''bash ffplay'''\

### path installation

***Termux***\
    because of termux is setup, it is very easy to put scripts in $PATH, so i created a dedicated script that installs all the depedencies using pkg.
to install using it just run:
'''git clone '''\
'''cd FFplay'''\
'''bash install.sh'''\
to run:
'''ffplay'''



