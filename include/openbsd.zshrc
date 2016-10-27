# vim: ft=zsh tabstop=4 textwidth=72 noexpandtab
#
# THIS FILE INCLUDES everything and anything that is specific to 
# a particular operating system and included as ${(L)$(uname)}.zshrc
# so
#    openbsd, linux, darwin, etc

AsRoot='/usr/bin/doas'
SYSLOCAL='/usr/local'
LS_OPTIONS='-FG'

function ls { $SYSLOCAL/colorls ${=LS_OPTIONS} $argv; }

export SYSLOCAL

# Copyright (C) 2016 by Tom Davis <tom@tbdavis.com>.
