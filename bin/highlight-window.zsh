#!/usr/bin/env zsh
# @(#)[:6ZoGC1s^*eFZG9n(awN*: 2017/04/25 20:42:30 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86
:needs xwd xdotool convert

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t"
	'  %T-v%t  verbose and %Sspecial%s.'
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

typeset -i windowid=$1

xdotool windowraise $windowid
on_error -die "No such window %B${windowid:gs/%/%%}%b."

typeset -i WINDOW X Y WIDTH HEIGHT SCREEN
eval "$( xdotool getwindowgeometry --shell $windowid )"
(( WINDOW == windowid )) || -die 'Weird window results.' $windowid $WINDOW

typeset -i win_dsktp=$( eval xdotool get_desktop_for_window $windowid )
typeset -i cur_dsktp=$( eval xdotool get_desktop )
(( win_dsktp == cur_dsktp )) || xdotool set_desktop $win_dsktp

typeset -- dout=$( mktemp -d )
trap "cd ~; rm -rf $dout;" EXIT
cd $dout || -die "Could not %Tcd%t to %B${dout:gs/%/%%}%b."

typeset -- fimg=$windowid.xwd
xwd -silent -id $windowid -out $fimg
convert -size ${WIDTH}x${HEIGHT} canvas:orange orange.png
convert $fimg -colorspace Gray mask.png
convert $fimg orange.png mask.png -composite blent.png

# do the display
typeset -- imgname=${windowid}-${RANDOM}
display -title $imgname -geometry +$X+$Y blent.png &
typeset -- imgpid=$!
sleep 0.3
imgwinid=$(xdotool search --name $imgname)

repeat 2; do
	xdotool windowraise $windowid
	sleep 0.2
	xdotool windowraise $imgwinid
	sleep 0.3
done
kill $imgpid


# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
