# @(#)[csongor.zshrc 2016/10/27 05:18:44 tw@csongor.lan]
# vim: tabstop=4 filetype=zsh

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
