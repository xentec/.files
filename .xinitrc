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

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Youtube...
VDPAU_NVIDIA_NO_OVERLAY=1

exec awesome
