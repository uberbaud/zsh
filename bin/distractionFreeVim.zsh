#!/usr/local/bin/zsh
# @(#)[:bwUW;}EezCL~Uv-{BbhH: 2017/05/13 00:57:57 tw@csongor.lan]

emulate -L zsh
. $USR_ZSHLIB/common.zsh || exit 86
:needs xterm vim

# Usage {{{1
typeset -- this_pgm=${0##*/}
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [ %T-n%t %Umsg%u ] [%Ufile%u]"
	'  %T-n%t _msg_  create a %Bnew%b file'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad-programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
typeset -- make_new=false
typeset -- rcs_msg=''
while getopts ':n:h' Option; do
	case $Option in
		h)	usage "${Usage[@]}";								;;
		n)	make_new='true'; rcs_msg="$OPTARG";					;;
		\?)	-die "Invalid option: '-$OPTARG'.";					;;
		\:)	-die "Option '-$OPTARG' requires an argument.";		;;
		*)	bad-programmer "$Option";							;;
	esac
done
# cleanup
unset -f bad-programmer
# remove already processed arguments
shift $(($OPTIND - 1))
# ready to process non '-' prefixed arguments

((1<$#))&& -die 'Unexpected arguments. Only wanted %Ufile name%u.'
# /options }}}1

if $make_new; then
	[[ -f $1 ]]&& -die "%B${1:gs/%/%%}%b already exists."
	$USRBIN/new -n -t 'rem' $1 $rcs_msg
	on-error -die "Could not create a new file %B${1:gs/%/%%}%b."
else
	(($#==0))&& -die 'Missing required argument %Ufile name%u.'
fi

typeset -a vim_opts=(
	# STRINGS with spaces MUST BE ESCAPED for [*] expansion
	-u "'$XDG_CONFIG_HOME/vim/disfree.rc'"
	"'$1'"	# file name
  )

declare -a disFree=(
	-b			90
	-class		'disFreeTerm'
	-e			"vim $vim_opts"
  )

xterm "${disFree[@]}" >/dev/null 2>&1 &!

# Copyright (C) 2015 by Tom Davis <tom@greyshirt.net>.
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab
