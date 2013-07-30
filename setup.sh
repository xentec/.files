#!/bin/bash

cd $(dirname $(readlink -fn $0))

# Colors
N="\033[0m"	# unsets color to term's fg color

G="\033[0;32m"
EMR="\033[1;31m"
EMG="\033[1;32m"

function lnk {
	echo -e "${N}Linking$G $2 ${N}to$G $1 $N"
	ln -Ts $1 $2 &> /dev/null
	if [ $? != 0 ]; then
		if [ -L $2 ]; then 
			echo -e "$EMR !W: ${G}$2${N} is a symlink to$G $(readlink -fn $2)${N}"
		else
			mv -T $2 $2.old
			echo -e "$EMR !W: ${G}$2${N} already exists! renamed to $G$2.old${N}"
			ln -Ts $1 $2
			if [ $? != 0 ]; then
				echo -e "${EMR} !E: Aborted$N"
				exit
			fi
		fi
	fi
}

# Link all configs
for CONFIG in .config/*; do
	lnk $PWD/$CONFIG ~/$CONFIG
done

# Link others
for DIR in .local/*; do
	lnk $PWD/$DIR ~/$DIR
done


# Bash
lnk $PWD/.bashrc ~/.bashrc
lnk $PWD/.bash.d ~/.bash.d

echo -e ${EMG}Done!$N
cd $OLDPWD
