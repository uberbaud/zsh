# @(#)[:wkw`{efd$J;K*R?O52uC: 2017/03/05 06:12:13 tw@csongor.lan]
# vim: ft=zsh tabstop=4 textwidth=72 noexpandtab
#
# THIS FILE INCLUDES everything and anything that is specific to 
# a particular operating system and included as ${(L)$(uname)}.zshrc
# so
#    openbsd, linux, darwin, etc

SYSLOCAL='/usr'
LS_OPTIONS='-F --color=auto'

function ls { $SYSLOCAL/bin/ls ${=LS_OPTIONS} $argv; }

typeset -- AsRoot='/usr/bin/sudo'
export SYSLOCAL

# Copyright (C) 2016 by Tom Davis <tom@tbdavis.com>.
