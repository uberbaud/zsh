#!/usr/bin/env zsh
# @(#)[:!qoFKJRWTqV74SCjJrLd: 2017/06/11 04:48:09 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

emulate -L zsh
. $USR_ZSHLIB/common.zsh|| exit 86

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t"
	'  Starts or switches to %BIRC%b client.'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
typeset -- verbose=false
while getopts ':hv' Option; do
	case $Option in
		h)	-usage $Usage;										;;
		v)	verbose=true;										;;
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

typeset -- app=hexchat
typeset -- appbin==$app # =$appbin is the executable path
:needs $appbin xdotool
#:needs mkdir nohup ln

exec  >> ${HOME}/log/$app 2>&1

xdotool set_desktop ${dskWIDGIT:-6}

pgrep -q \^$app\$ && {
	printf "### ${app:gs/%/%%} is already running.\n\tpid: "
	pgrep \^$app\$
	return 0
  }

printf "### Starting ${app:gs/%/%%}."
nohup $appbin $@ &!

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
