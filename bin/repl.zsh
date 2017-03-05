#!/usr/bin/env zsh
# @(#)[:)VnqL(zm1HA&2=Hq}0*^: 2017/03/05 06:20:29 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [%T-e%t %Urun cmd%u] %Usources …%u"
	'  Calls %Tbuild%t with all the args except the optional %T-r%t.'
	'  %T-e%t  Executes the command, otherwise executes the first source'
	'      name witout the %S.c%s suffix.'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
typeset -- runcmd=''
while getopts ':he:' Option; do
	case $Option in
		h)	-usage $Usage;										;;
		e)	runcmd=$OPTARG;										;;
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

[[ -z $runcmd ]]&& runcmd=${1%.c}
[[ $runcmd =~ '/' ]]|| runcmd=./$runcmd

typeset -- csrc=${1%.c}.c
typeset -- vimswap
:vim-swap-file-name $csrc | :assign vimswap

while $LOCALBIN/watch-file $csrc; do
	[[ -f $vimswap ]]|| break
	printf '\e[0;0H\e[2J\e[3J'	# clear
	build $@
	$=runcmd
done


# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
