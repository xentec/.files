#!/bin/bash

cd $(dirname $(readlink -fn $0))

# Colors
N="\033[0m"	# unsets color to term's fg color

G="\033[0;32m"
Y="\033[0;33m"
EMY="\033[1;33m"
EMR="\033[1;31m"
EMG="\033[1;32m"

function lnk {
	echo -en "   $G $2 ${N}=>$G $1 $N"
	ln -Ts $1 $2 &> /dev/null
	if [ $? != 0 ]; then
		if [ -L $2 ]; then 
			echo -en "$EMY!$N"
		else
			mv -T $2 $2.old
			echo -en "$EMY!! => $G${2}.old$N"
			ln -Ts $1 $2
			if [ $? != 0 ]; then
				echo
				echo -e "${EMR}!E: Aborted$N"
				exit
			fi
		fi
	fi
	echo
}


echo -n "Loading dependencies...  "
git submodule init && git submodule update && echo -e "${G}Done$N" \
	    || echo -e "${EMG}Failed$N"


echo "Building..."
# cv
(cd extern/cv && make)

echo "Linking..."
echo -e "  .config"

# Link all configs
for CONFIG in .config/*; do
	lnk $PWD/$CONFIG ~/$CONFIG
done

# Link all fonts
echo "  .fonts"
mkdir -p ~/.fonts
for FONT in .fonts/*; do
	lnk $PWD/$FONT ~/$FONT
done
echo "    ..cache.. "
fc-cache

# Link others
echo "  .local"
mkdir -p ~/.local/bin
for DIR in .local/bin/*; do
	lnk $PWD/$DIR ~/$DIR
done

# Bash
echo "  bash"
lnk $PWD/.bashrc ~/.bashrc
lnk $PWD/.bash.d ~/.bash.d
# vim
echo "  vim"
lnk $PWD/.vimrc ~/.vimrc
# X
echo "  X"
lnk $PWD/.xinitrc ~/.xinitrc
lnk $PWD/.Xresources ~/.Xresources


echo -e "${EMG}Done!$N"
cd $OLDPWD
