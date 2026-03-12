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

> [!IMPORTANT]
>use **"bash"** **not "sh"** 
>as **it does not support the features used by FFplay!**

run:
```
git clone https://github.com/Felipeshaolin/FFplay.git
cd FFplay 
bash ffplay
```

### path installation

***Termux***

because of how termux is setup, it is very easy to put scripts in $PATH, so i created a dedicated script that installs all the depedencies using pkg.
to install using it just run:

```
git clone https://github.com/Felipeshaolin/FFplay.git
cd FFplay
bash install.sh
#to run:
ffplay
```

***other platforms***

you sadly cannot use install.sh/uninstall.sh outside of an termux environment. But you can still compile the code by yourself.To do so install the necessary depedencies with your package manager and execute these commands:

```
git clone https://github.com/Felipeshaolin/FFplay.git
cd FFplay
shc -f FFplay.sh -o ffplay

#to run
ffplay
```




