# vim: ft=zsh tabstop=4 textwidth=72 noexpandtab
#
# THIS FILE INCLUDES everything and anything that is specific to 
# a particular operating system and included as ${(L)$(uname)}.zshrc
# so
#    openbsd, linux, darwin, etc

SYSLOCAL='/usr'
LS_OPTIONS='-F --color=auto'

function ls { $SYSLOCAL/bin/ls ${=LS_OPTIONS} $argv; }

export SYSLOCAL

# Copyright (C) 2016 by Tom Davis <tom@tbdavis.com>.
