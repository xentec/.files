#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Colors
source .bashrc.d/colors
eval $(dircolors -b .bashrc.d/dir_colors)

UC=$G                   	# user's color
[ $UID -eq "0" ] && UC=$R       # root's color

# Prompt
##########################
PS1="$UC\u$N@$EMC\h$N :: $B\t$N :: \w \n \$(RET=\$?; [[ \$RET != 0 ]] && echo '$R'\$RET'$N ' )$EMY»$N "

# Aliases
###########################
alias ls='ls --color=auto'
alias snano='sudo nano'
alias lg='sudo -iu $1'

# Defaults
export EDITOR=nano

# source .bashrc.d/archnews
