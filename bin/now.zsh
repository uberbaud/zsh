#!/usr/bin/env zsh
# @(#)[:3gccJoE)9RJ6x{O,2Gx{: 2017/03/05 06:19:59 tw@csongor.lan]
# vim: ft=zsh tabstop=4 textwidth=72 noexpandtab

# helper functions {{{1
function notify { # {{{2
	typeset -- prefix_1=$1
	typeset -- prefix_n=$2
	print -Pu 2 $prefix_1 $3
	shift 3
	for line in $@; do
		print -Pu 2 $prefix_n $line
	done
	exit 0
  }; # }}}2
function usage { # {{{2
	notify '  %F{4}Usage%f:' '        ' $@
	exit 0
  }; # }}}2
function die { # {{{2
	notify '  %F{1}FAILED%f:' '         ' $@
	exit 1
  }; # }}}2
# }}}1
# declarations {{{1
typeset -r  date='%Y-%m-%d'
typeset -r  time='%H:%M:%S'
typeset --  tz=' %z'
typeset --  separator=' '
typeset -i  date_only=0
typeset -a  opts

# usage {{{2
typeset -a Usage=(
	"%F{2}$(basename $0)%f [%F{2}-d%f] [%F{2}-t%f] [%F{2}-u%f]"
	'prints the current timestamp with the timezone'
	'%F{2}-d%f  date only, no time nor timezone'
	'%F{2}-t%f  use the "T" delimiter between the date and time'
	'%F{2}-u%f  output UTC'
	'%F{2}-z%f  output UTC with Z instead of timeoffset'
	'%F{2}-h%f  help'
); # }}}2
# }}}1
# process -opts {{{1
while getopts ':utdzh' Option; do
	case $Option in
		d)	date_only=1;										;;
		h)	usage "${Usage[@]}";								;;
		t)	separator='T';										;;
		u)	opts+=( '-u' );										;;
		z)	opts+=( '-u' ); separator='_'; tz='Z';				;;
		\?)	die "Unknown option: '-$OPTARG'.";					;;
		\:)	die "Option '-$OPTARG' requires an argument.";		;;
		*)	echo "doing the default thing with '$OPTARG'.";		;;
	esac
done
shift $(($OPTIND - 1))	; # ready to process non '-' prefixed arguments
# /opts }}}1

format="${date}"
test $date_only -eq 1 || format+="${separator}${time}${tz}"

/bin/date $opts +"$format"

# Copyright (C) 2009 by Tom Davis <tom@tbdavis.com>.
