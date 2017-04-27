#!/usr/bin/env zsh
# @(#)[:y;3WVD_tAV|!DQQ6m<Bq: 2017/04/27 06:06:51 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh || exit 86
:needs awk

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t"
	'  Gets an email address matching the arguments'
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

[[ -n ${XDG_DATA_HOME:-} ]]|| -die '%BXDG_DATA_HOME%b is not set.'
typeset -- emailf=${XDG_DATA_HOME}/sysdata/emails.tsv
[[ -f $emailf ]]|| -die "Can't find the email file."

# lowercased, with anything between, and no punctuation etc
typeset -- pattern=${(L)${(j:.*:)${(z)"${*//[[:punct:]]/}"}}}

typeset -a awkpgm=(
	'{'
		'l=tolower($1);'			# look for lowercased bits,
		'gsub("[[:punct:]]","",l)'	# no punctuation
	'}'
	"l~/${pattern}/" '{print "\""$1"\" <"$2">"}'
  )

awk -F'\t' "$awkpgm" $emailf

# Copyright © 2017 by Tom Davis <tom@greyshirt.net>.
