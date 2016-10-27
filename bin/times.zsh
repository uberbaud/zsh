#!/usr/bin/env zsh
# $Id: times.zsh,v 1.2 2016/10/25 07:09:12 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. "$USR_ZSHLIB/common.zsh"

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t"
	'  '
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

[[ $1 == <-> ]]|| -die 'First arg is not an integer.'
typeset -i times=$(($1+1))
shift

typeset -r xpath=$(mktemp -d)
[[ -n $xpath ]]|| -die 'Could not make a temp directory'

typeset -r xfile=$xpath/cmd.sh
exec 3>$xfile
print -nu 3 '#!'
which ksh >&3
print -nu 3 'for lVKd0 in'
for i in {1..$times}; do print -nu 3 ' x'; done
print -u 3 -- $'\ndo'
print -u 3 -- "  ${(qq)@}"
print -u 3 -- 'done'
exec 3>&-

[[ -n ${DEBUG:-} ]]&& {
	echo $xfile
	echo '----'
	cat < $xfile
  }

chmod 0700 $xfile

/usr/bin/time $xfile

[[ -z ${DEBUG:-} ]]&& {
	rm $xfile
	rmdir $xpath
  }

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
