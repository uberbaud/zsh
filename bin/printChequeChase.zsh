#!/usr/bin/env zsh
# @(#)[:K1+CkAE;MRJnP^y`9ua2: 2017/02/26 16:24:04 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh || exit 86
:needs printCheque

typeset -F 2 defAmount=200.00

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t "'[%T%U$$$.¢¢%u%t]'
	'  Prints %SChase%s cheque using %TprintCheque.pl%t'
	'  %T%U$$$.¢¢%u%t  is the numerical amount. %U.cents%u is optional.'
	"          defaults to %S\$${defAmount}%s if unspecified."
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

(($#<2))|| -die 'Too many arguments. At most, one (1) expected.'

typeset -- payTo='Chase Card Services'
typeset -F 2 amount=${1:-$defAmount}
typeset -- memo="Acct 4325 5370 0318 1683"

((amount))|| -die '%S$amount%s is %S0.00%s.' 'Hint: not a number?'

printCheque -t $payTo -$ $amount -m $memo
on-error 'Could not print the cheque.'

# Copyright (C) 2014,2017 by Tom Davis <tom@greyshirt.net>.
