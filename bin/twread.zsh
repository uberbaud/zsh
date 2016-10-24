#!/usr/bin/env zsh
# $Id: twread.zsh,v 1.1 2016/07/11 02:47:08 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. "$USR_ZSHLIB/common.zsh"

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t %Ufile name%u"
	'  Shows a text file in %Sxmessage%s.'
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

(($# == 0))&& -die 'Missing required parameter, %Ufile name%u.'
(($# >= 2))&& -die 'Too many parameters. Expected one (1).'

typeset -- file=$1
[[ -a $file ]]|| -die "%B${file:gs:/%/%%}%b does not exist."
[[ -f $file ]]|| -die "%B${file:gs:/%/%%}%b is not a file."

typeset -a opts=(
	-buttons	'close:0'
	-default	'close'
	-fn			'-misc-dejavu sans mono-medium-r-*-*-*-140-*-*-m-*-*-*'
	-geometry	957x1080-0+0
  )

/usr/X11R6/bin/xmessage $opts -file $file


# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
