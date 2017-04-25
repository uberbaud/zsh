#!/usr/bin/env zsh
# @(#)[:n~GV;-)nFPG2|s%`|hND: 2017/04/25 20:30:51 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh || exit 86

:needs uname /usr/bin/script

tspath=${HOME}/hold/$(uname -r)/typescripts
tsfout=ts-$(date -u +'%Y%m%d-%H%M%S')

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [%T-a%t] [%Uoutfile%u]"
	'  Wrapper around %T/usr/bin/script%t'
	'  %T-a%t  appends to the output script'
	'  %Uoutfile%u uses to that file instead of the default.'
	'  This wrapper writes to a date named file in'
	"      %S${tspath:gs/%/%%}%s by default."
	'      Giving any options on the command line will disable this'
	'      wrapping effect.'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
while getopts ':h' Option; do
	case $Option in
		h)	-usage $Usage;										;;
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

local scptopts=( $@ )

(($#))|| (){
	[[ -d $1 ]]|| mkdir -p $1
	[[ -d $1 ]]||
		{ warn "Could not create %B${1:gs/%/%%}%b."; return; }
	local a='' e=''
	for a in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
		[[ -f ${1}/${2}$e ]]|| { e=$a; break; }
	done
	[[ -f ${1}/${2}$e ]]&& { warn "Can't find a new name."; return; }
	scptopts=( ${1}/${2}$e )
  } $tspath $tsfout

exec /usr/bin/script $scptopts

# Copyright © 2017 by Tom Davis <tom@greyshirt.net>.
