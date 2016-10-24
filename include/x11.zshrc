# $Id: x11.zshrc,v 1.3 2016/10/23 02:32:51 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

WRAP:FUNCTION pbcopy	$SYSLOCAL/bin/xclip -selection clipboard -in
WRAP:FUNCTION pbpaste	$SYSLOCAL/bin/xclip -selection clipboard -out
WRAP:FUNCTION xlock		/usr/X11R6/bin/xlock +description
WRAP:FUNCTION xfontsel	/usr/X11R6/bin/xfontsel -print -scaled

WRAP:FUNCTION firefox	$USRBIN/start-firefox --new-tab


### x11
function R { # {{{1
	$SYSLOCAL/bin/xdotool windowraise $WINDOWID
}	; # }}}1
# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
