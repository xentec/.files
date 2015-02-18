#!/bin/bash
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# simplifying including
PWDIR=$(pwd)
cd $(dirname $(readlink -fn ${BASH_SOURCE[0]}))

source .path

# Getting back
cd $PWDIR


# Make rxvt nicer
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Youtube...
export VDPAU_NVIDIA_NO_OVERLAY=1

# disable pc speaker
xset -b

# and fix Steam
# export STEAM_RUNTIME=0 not yet
export STEAM_FRAME_FORCE_CLOSE=1

# Java unuglyfier
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'
