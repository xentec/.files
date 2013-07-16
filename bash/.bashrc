#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# simplifying including
PWDIR=$(pwd)
cd $(dirname $(readlink -fn ${BASH_SOURCE[0]}))

# Path
export PATH=~/.local/bin:$PATH

# Colors
##########################
source .bashrc.d/colors
eval $(dircolors -b .bashrc.d/dir_colors)
 # Host color
source .bashrc.d/machine_colors

UC=$G                   	# user's color
[ $UID -eq "0" ] && UC=$R       # root's color

# Prompt
##########################
PS1="$UC\u$N@$MACOL\h$N :: $B\t$N :: \w \n \$(RET=\$?; [[ \$RET != 0 ]] && echo '$R'\$RET'$N ' )$EMY»$N "

# Aliases
alias ls='ls -F --color=auto'
alias ll='ls -l'
alias snano='sudo nano'
alias lg='sudo -iu $1'

# Defaults
export EDITOR=nano

# source .bashrc.d/archnews
##########################
# Getting back
cd $PWDIR
