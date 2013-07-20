#!/bin/bash

DIR=$(dirname $(readlink -fn $0))

function lnk {
	ln -s $1 $2
	if [ $? != 0 ]; then
		mv $2 $2.old
		echo "$2 already exists: renamed to $2.old"
		ln -s $1 $2
    fi
}

# Link all configs
for CONFIG in .config/*; do
        lnk $DIR/$CONFIG ~/$CONFIG
done

# Bash
lnk $DIR/.bashrc ~/.bashrc
lnk $DIR/.bash.d ~/.bash.d

echo Done!

