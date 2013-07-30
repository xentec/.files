#
# ~/.bashrc
#

# Path
export PATH=~/.local/bin:$PATH

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# simplifying including
PWDIR=$(pwd)
cd $(dirname $(readlink -fn ${BASH_SOURCE[0]}))

# Colors
##########################
eval $(dircolors -b .bash.d/dir_colors)
source .bash.d/colors
source .bash.d/machine_colors

UC=$G						# user's color
[ $UID -eq "0" ] && UC=$R	# root's color

# Prompt
##########################
PS1=\
"$UC\u$N@$MACOL\h$N :: \
$B\t$N :: \
\w $G(\$(ls -1 | wc -l | sed 's: ::g')+.\$(ls -A1 | grep '^\.' | wc -l | sed 's: ::g') files, \$(LC_ALL=C ls -lah | grep -m 1 total | sed 's/total //')b)$N \n \
\$(RET=\$?; [[ \$RET != 0 ]] && echo '$R'\$RET'$N ' )$EMY»$N "

# Aliases
alias ls='ls -F --color=auto'
alias ll='ls -l'
alias snano='sudo nano'
alias lg='sudo -iu $1'

# Defaults
export EDITOR=nano

# source .bash.d/archnews
##########################
# Getting back
cd $PWDIR
