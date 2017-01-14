#!/usr/bin/env zsh
# @(#)[:D{?[ƒ.zsh 2016/10/25 07:09:12 tw@csongor.lan]#Xmt4Cuie6s5pPRz: 2017/01/14 20:36:58 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [-l|-p %Iprnopts%i]"
	"  Performs a function from %B${USR_ZSHLIB:gs/%/%%}/common.zsh%b."
	'  If the output is to a TTY, %S\0%s will be converted to %S\n%s.'
	'  -p  options used for the %Tprint%t command.'
	'  -l  list available functions.'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function listopts { # {{{2
	print -c -- $(print -l -- $USR_ZSHLIB/*(.:t) | egrep -v '\.')
} # }}}2
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
typeset -a prnopts=()
while getopts ':hlp:' Option; do
	case $Option in
		h)	-usage $Usage;										;;
		p)	prnopts+=( $OPTARG );								;;
		l)	listopts; exit 0;									;;
		\?)	-die "Invalid option: '-$OPTARG'.";					;;
		\:)	-die "Option '-$OPTARG' requires an argument.";		;;
		*)	bad_programmer "$Option";							;;
	esac
done
# cleanup
unset -f bad_programmer
# remove already processed arguments
shift $(($OPTIND - 1))
# ready to process non '-' prefixed arguments
# /options }}}1

typeset -- res=$( $@; echo $? )
typeset -i rc=$res[-1]
unset 'res[-1]'

(($#res))|| exit rc

if [[ -t 1 ]]; then
	print -n $prnopts -- ${(0)res}
else
	print -n $prnopts -- $res
fi

exit rc

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
