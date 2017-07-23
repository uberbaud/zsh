# @(#)[:$PwGOxb)-3O5}EjD*CEL: 2017/07/23 05:32:10 tw@csongor.lan]
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
	# we can cusomize ZSH glob sorting with greater granularity,
	# so use -f to disable colorls resorting in a different order,
	# BUT -f implies -a(?!?!), which we don't want, but can work around 
	# by using -d * if we don't find any files
	local workaround=()
	local wantNoSort=true
	local flags=( $argv[1,$(($argv[(i)--]-1))] ) # !!! discards empties
	(($flags[(I)-*r*])) && wantNoSort=false
	(($flags[(I)-*S*])) && wantNoSort=false
	(($flags[(I)-*x*])) && wantNoSort=false
	$wantNoSort && {
		workaround=( -f )
		# if we have anything that looks like a file (not a flag)
		(($argv[(I)[^-]*]))|| (){
			# special case of -- used as a file name on the command line
			(($argv[(i)--])) && {				# there is at least one '--'
				(($argv[(i)--]!=$argv[(I)--]))|| # there is MORE than one
					return 0
			  }
			# if there aren't any files here, we don't need to do any 
			# more work
			[[ -n *(#qN) ]]|| return 1
			workaround+=( -d -- * )
		  } || return 0
	  }
	$SYSLOCAL/bin/colorls ${=LS_OPTIONS} $workaround $argv
}

export SYSLOCAL

# Copyright (C) 2016 by Tom Davis <tom@tbdavis.com>.
