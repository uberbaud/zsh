#!/usr/bin/env zsh
# @(#)[:*|=n6Nh+Y~3f?}a5iiM): 2017/01/24 03:05:10 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh || exit 86

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t"
	'  Show a weather graph for charlotte'
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

:needs :x11 curl display disown

typeset -- graph_url='http://forecast.weather.gov/meteograms/Plotter.php'
typeset -a graph_opts=(
	lat='35.39'
	lon='-80.71'
	wfo='GSP'
	zcode='NCZ072'
	gset='18'
	gdiff='3'
	unit='0'
	tinfo='EY5'
	ahour='0'
	pcmd='11100011101110000000000000000000000000000000000000000000000'
	lg='en'
	indu='1'
  )

setopt auto_continue no_hup no_check_jobs no_monitor no_notify
() {
	curl -sL $graph_url\?${(j:&:)graph_opts}	\
	| display -immutable -geometry 800x600+1100+20 -
  }  >/dev/null 2>&1 &
disown

# Copyright © 2017 by Tom Davis <tom@greyshirt.net>.
