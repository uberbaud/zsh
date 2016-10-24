# $Id: csongor.zshrc,v 1.3 2016/10/23 02:58:43 tw Exp $
# vim: tabstop=4 filetype=zsh

SYSLOCAL='/usr/local'

CSONGOR_XTERM_WINDOW_BG='#FFFFFF'
CSONGOR_XTERM_WINDOW_FG='#000000'

typeset -xm 'CSONGOR_XTERM_*'
function set-colors-bg-fg {
	printf '\e]11;%s\a\e]10;%s\a' $1 $2
}
function csongor-colors {
	set-colors-bg-fg $CSONGOR_XTERM_WINDOW_BG $CSONGOR_XTERM_WINDOW_FG
}
csongor-colors

# Copyright (C) 2015 by Tom Davis <tom@tbdavis.com>.
