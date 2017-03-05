# @(#)[:M&GklsIJ=CH3~K~NnOT,: 2017/03/05 06:07:53 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

WRAP:FUNCTION pbcopy	/usr/local/bin/xclip -selection clipboard -in
WRAP:FUNCTION pbpaste	/usr/local/bin/xclip -selection clipboard -out
WRAP:FUNCTION xlock		/usr/X11R6/bin/xlock +description
WRAP:FUNCTION xfontsel	/usr/X11R6/bin/xfontsel -print -scaled

WRAP:FUNCTION firefox	$USRBIN/start-firefox --new-tab

function R { # {{{1
	/usr/local/bin/xdotool windowraise $WINDOWID
}	; # }}}1

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
