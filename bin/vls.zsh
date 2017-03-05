#!/usr/bin/env zsh
# @(#)[:7`dJEfcR5Xy0cV2q,&=Z: 2017/03/05 06:20:39 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t"
	'  Lists files being edited using %Tvim%t.'
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

typeset -- vimcache=$XDG_DATA_HOME/vim/cache
typeset -a infos=( ${(f)"$(
	/usr/bin/fstat $vimcache/%* | /usr/bin/egrep ' vim '
  )"} )

typeset -a desktops=()

for fstatln in $infos; do
	typeset -a info=( ${(z)fstatln} )
	typeset -i pid=$info[3]
	typeset -- nam=${${info[10]##*/}:gs/%/\/}
	typeset -i wid=$( :x11-get-winid-from-pid $pid )
	typeset -i dsk=$( xdotool get_desktop_for_window $wid )
	desktops[dsk]+=" $nam"
done

typeset -i n=$( xdotool get_num_desktops )
for (( i=1; i<=n; i++ )); do
	[[ -n ${desktops[i]:-} ]] || continue
	typeset -aU dirs=($(
		for d in ${${(z)desktops[i]}%/*}; do
			[[ $d =~ "^$HOME" ]] && echo "~${d#$HOME}"
		done
	  ))
	print -P "%BDesktop $i%b"
	print -lD "  ${(@)^dirs}"
done


# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
