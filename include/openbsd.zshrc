# @(#)[:$PwGOxb)-3O5}EjD*CEL: 2017/07/25 01:24:15 tw@csongor.lan]
# vim: ft=zsh tabstop=4 textwidth=72 noexpandtab
#
# THIS FILE INCLUDES everything and anything that is specific to 
# a particular operating system and included as ${(L)$(uname)}.zshrc
# so
#    openbsd, linux, darwin, etc

AsRoot='/usr/bin/doas'
SYSLOCAL='/usr/local'
LS_OPTIONS='-FG'

function ls {
	local lsbin="$(whence -p colorls)"
	[[ $lsbin == 'colorls not found' ]]&& lsbin="$(whence -p ls)"
	$lsbin $LS_OPTIONS $@
}

export SYSLOCAL

# Copyright (C) 2016 by Tom Davis <tom@tbdavis.com>.
