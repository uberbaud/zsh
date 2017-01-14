#!/usr/bin/env zsh
# @(#)[newest.zsh 2016/10/25 07:08:53 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86

typeset -i howmany=1
typeset -- where='.'
typeset -- glob='*'

typeset -- ftype='.'
typeset -- tail=''
typeset -i ftc=0

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t -[dflpsx] [-v] [%Ucount%u] [%Upath%u] [%Uglob%u]"
	'  Shows the newest %Ucount%u fsobjects in %Upath%u matching %Uglob%u.'
	'    %Upath%u, %Ucount%u, and %Uglob%u can be in any order.'
	'    To force a directory that looks like a number to be considered'
	'    as a count, append a slash.'
	'  %T-a%t  Consider all fsobjects.'
	'  %T-d%t  Consider only %Sdirectories%s.'
	'  %T-l%t  Consider only %Slinks%s.'
	'  %T-p%t  Consider only %Spipes%s.'
	'  %T-s%t  Consider only %Ssockets%s.'
	'  %T-x%t  Consider only %Sexecutables%s.'
	"  %T-q%t  don't show path."
	"  %Upath%u defaults to %S${where:gs/%/%%}%s."
	"  %Ucount%u defaults to %S${howmany:gs/%/%%}%s."
	"  %Uglob%u defaults to %S${glob:gs/%/%%}%s."
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
while getopts ':adlpsxvh' Option; do
	case $Option in
		a)	ftype='';  (( ftc++ ));								;;
		d)	ftype='/'; (( ftc++ ));								;;
		l)	ftype='@'; (( ftc++ ));								;;
		p)	ftype='p'; (( ftc++ ));								;;
		s)	ftype='='; (( ftc++ ));								;;
		x)	ftype='*'; (( ftc++ ));								;;
		v)	tail=':t';											;;
		h)	-usage $Usage;										;;
		\?)	-die "Invalid option: '-$OPTARG'.";					;;
		\:)	-die "Option '-$OPTARG' requires an argument.";		;;
		*)	bad_programmer "$Option";							;;
	esac
done
(( ftc > 1 )) && -die 'Too many %Sonly show this type%s flags.'
# cleanup
unset -f bad_programmer
# remove already processed arguments
shift $(($OPTIND - 1))
# ready to process non '-' prefixed arguments
# /options }}}1

typeset -- reminder="Reminder: %Uglob%u metacharacters MUST be quoted."

(( $# <= 3 )) || -die 'Too many parameters.' $reminder

typeset -i hset=0
typeset -i wset=0
typeset -i gset=0

while (( $# )); do
	if [[ $1 == <-> ]]; then
		(( hset++ )) && -die 'Too many %Scount%s parameters.'
		howmany=$1
	elif [[ $1 =~ '[*?]' ]]; then
		(( gset++ )) && -die 'Too many %Scount%s parameters.'
		glob=$1
	elif [[ -d $1 ]]; then
		(( wset++ )) && -die 'Too many %Scount%s parameters.'
		where=$1
	else
		-die "Don't know what to do with %S${1:gs/%/%%}%s." $reminder
	fi
	shift
done

[[ $(readlink -f $where) == $PWD ]] && tail=':t'

eval "print -c $where/$glob(${ftype}om[1,$howmany]$tail)"

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
