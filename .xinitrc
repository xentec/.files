#!/bin/sh
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

export PATH=~/.local/bin:$PATH

# Make rxvt nicer
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Youtube...
export VDPAU_NVIDIA_NO_OVERLAY=1

# disable pc speaker
xset -b

# and fix Steam
# export STEAM_RUNTIME=0 not yet
export STEAM_FRAME_FORCE_CLOSE=1

exec awesome
