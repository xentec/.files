#
# ~/.bashrc
#

# Path
USEREXEC=~/.local/bin

if [[ $PATH != *$USEREXEC* ]]; then
	export PATH=$USEREXEC:$PATH
fi

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

# Less Colors for Man Pages
man() {
	env \
	LESS_TERMCAP_mb=$'\E[01;31m'		\
	LESS_TERMCAP_md=$'\E[01;38;5;74m'	\
	LESS_TERMCAP_me=$'\E[0m'		\
	LESS_TERMCAP_so=$'\E[38;5;246m'		\
	LESS_TERMCAP_se=$'\E[0m'		\
	LESS_TERMCAP_us=$'\E[04;38;5;146m'	\
	LESS_TERMCAP_ue=$'\E[0m'		\
	man "$@"
}

UC=$G				# user's color
[ $UID -eq "0" ] && UC=$R	# root's color

# Prompt
##########################
PS1=\
"$UC\u$N@$MACOL\h$N :: \
$EMB\t$N :: \
$EMG\w $G(\$(ls -1 | wc -l | sed 's: ::g')+.\$(ls -A1 | grep '^\.' | wc -l | sed 's: ::g') files, \$(LC_ALL=C ls -lah | grep -m 1 total | sed 's/total //')b)$N \n \
\$(RET=\$?; [[ \$RET != 0 ]] && echo '$R'\$RET'$N ' )$EMY»$N "

# Defaults
export EDITOR=vim
export MPD_HOST=keeper

# Aliases
alias ls='ls -F --color=auto'
alias ll='ls -l'
alias lg='sudo -iu $1'
alias sedit="sudo -E $EDITOR"
alias sread="sudo -E less"


source .bash.d/local 2&> /dev/null
##########################
# Getting back
cd $PWDIR
