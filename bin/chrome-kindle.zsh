#!/usr/bin/env zsh
# @(#)[:hn%CzhwvInwIJYnO|=Yp: 2017/02/16 21:58:56 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh || exit 86

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t"
	'  Start chromium browser as kindle'
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

:needs chrome xdotool

URL=https://read.amazon.com/
CFGDIR=$XDG_CONFIG_HOME/kindle
LOG=$HOME/log/kindle


chrome --user-data-dir=$CFGDIR --app=$URL 1>$LOG 2>&1 &!

classname='read.amazon.com'
doopts=(
	search --classname $classname
	windowmove --sync 0 0
	windowsize --sync 1295 1082
  )

# try to move and position the window (maximum 15 seconds)
repeat 150 { sleep 0.1; xdotool $doopts && break; }
on-error -warn "Never found window with classname %B$classname%b."

# Copyright © 2017 by Tom Davis <tom@greyshirt.net>.
