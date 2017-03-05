# @(#)[:7+dy!qH&nJSkC|Gra#dT: 2017/03/05 06:04:46 tw@csongor.lan]
# vim: ft=zsh tabstop=4 textwidth=72 noexpandtab
#
# THIS FILE INCLUDES everything and anything that is specific to 
# a particular operating system and included as ${(L)$(uname)}.zshrc
# so
#    openbsd, linux, darwin, etc

AsRoot='/usr/bin/sudo'
SYSLOCAL='/usr/local'
LS_OPTIONS='-vbF'

function ls { /bin/ls ${=LS_OPTIONS} $@; }

function readlink {
	# we only handle the -nf filename bits
	(($#!=2))&&			{ /usr/bin/readlink $@; return $?; }
	[[ $1 == -n ]]&&	{ /usr/bin/readlink $@; return $?; }

	# if there is a -f, THIS is our only special handling
	[[ ${1:0:1} == '-' && $1 =~ f ]]&& {
		[[ $1 =~ '[^-fn]' ]]&& { die 'Unknown flag!'; return 1; }
		typeset -- fname=$( $USRBIN/getTrueName $2 )
		[[ -n $fname ]]|| return 1
		printf '%s' $fname
		[[ $1 =~ n ]]|| echo
		return 0
	}

	/usr/bin/readlink $@
}

export SYSLOCAL

# Copyright (C) 2016 by Tom Davis <tom@tbdavis.com>.
