#!/usr/bin/env zsh
# @(#)[:ztFaiaY~++hLvnDfRYGl: 2017/05/13 01:21:43 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

. $USR_ZSHLIB/common.zsh || exit 86

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%} -t%t %Utop%u %T-r%t %Uright%u %T-l%t %Uleft%u %T-b%t %Ubottom%u %Uin-file%u [%Uout-file%u]"
	'  Wrapper for pdfcrop'
	'    %T-t%t sets top coordinate.'
	'    %T-r%t sets right coordinate.'
	'    %T-l%t sets left coordinate.'
	'    %T-b%t sets bottom coordinate.'
	'  All are required but can also be set in the %Senvironment%s with'
	'    %STOP%s, %SRIGHT%s, %SLEFT%s, and %SBOTTOM%s.'
	'  Command line options override the %Senvironment%s.'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
integer TOP RIGHT LEFT BOTTOM
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
while getopts ':t:r:l:b:h' Option; do
	case $Option in
		t)	TOP=$OPTARG;										;;
		r)	RIGHT=$OPTARG;										;;
		l)	LEFT=$OPTARG;										;;
		b)	BOTTOM=$OPTARG;										;;
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

(($#<1))&&	-die 'Missing required argument %Sin-file%s.'
((2<$#))&&	-die 'Too many arguments. Expected one or two (1-2).'

:needs pdfcrop

badcoords=()
for v in TOP RIGHT LEFT BOTTOM; do
	((${(P)v}))&& continue
	badcoords+=( $v )
done

(($#badcoords))&& -die "Unset coordinates: %B${badcoords}%b."

pdfcrop --bbox "$LEFT $BOTTOM $RIGHT $TOP" $@


# Copyright © 2017 by Tom Davis <tom@greyshirt.net>.
