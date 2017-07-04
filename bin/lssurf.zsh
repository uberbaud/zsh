#!/usr/bin/env zsh
# @(#)[:4jZRQPc{A}C@VB@r=kph: 2017/07/04 02:12:28 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

emulate -L zsh
. $USR_ZSHLIB/common.zsh || exit 86

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [%T-l%t]"
	'  List current location urls of all surf2 windows.'
	'  %T-l%t  lists links under hover rather than location.'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
integer hover=0
while getopts ':lh' Option; do
	case $Option in
		l)	hover=1;											;;
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

:needs xdotool xprop

typeset -a query=(
	'_SURF_URI'		# location
	'WM_NAME'		# hover link
  )

typeset -a xids=( $( xdotool search --class '^Surf$' ) )
#(($#xids)|| -die 'Did not find any windows with %Bclass=%SSurf%s%b.'

typeset -- url
for id in $xids; do
	url=${${"$(xprop -id $id $query[hover+1])"%\"}#*\"}

	((hover))&& url=${url#* | }

	if [[ $url == http* || $url == ftp:* ]]; then
		printf '%s\n' $url
	elif [[ $url == file:* ]]; then
		printf '%s\n' ${${${url#file://}/#sPWD/.}/#$HOME/\~}
	fi
done

# Copyright © 2010,2017 by Tom Davis <tom@greyshirt.net>.
