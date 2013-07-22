#!/bin/bash

cd $(dirname $(readlink -fn $0))

# Colors
N="\033[0m"	# unsets color to term's fg color

Y="\033[0;33m"	# yellow
EMR="\033[1;31m"
G="\033[0;32m"

function lnk {
	echo -e "${N}Linking$G $2 ${N}to$G $1 $N"
	ln -Ts $1 $2 &> /dev/null
	if [ $? != 0 ]; then
		mv -T $2 $2.old
		echo -e "${EMR}$2 already exists:$N renamed to $G$2.old$N"
		ln -Ts $1 $2
		if [ $? != 0 ]; then
			echo -e ${EMR}Aborted$N
			exit
		fi
    fi
}

# Link all configs
for CONFIG in .config/*; do
        lnk $PWD/$CONFIG ~/$CONFIG
done

# Bash
lnk $PWD/.bashrc ~/.bashrc
lnk $PWD/.bash.d ~/.bash.d

echo Done!

cd $OLDPWD