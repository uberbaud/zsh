#!/usr/bin/env zsh
# $Id: v.zsh,v 1.31 2016/09/24 22:13:27 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

. $USR_ZSHLIB/common.zsh

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [%T-m%t %Umessage%u] [%T-f%t] %Ufile%u"
	'  %T-m%t  Use %Umessage%u as rcs checkin message.'
	"  %T-f%t  Force edit even if %Ufile%u isn't text."
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
typeset -- hasmsg=false;
typeset -- warnOrDie='die';
typeset -- rcsmsg='';
while getopts ':fhm:' Option; do
	case $Option in
		f)	warnOrDie='warn';									;;
		h)	-usage $Usage;										;;
		m)	hasmsg=true; rcsmsg=$OPTARG;						;;
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
function warnOrDie { #{{{1
	case $warnOrDie in
		die)  -die $@ 'Use %T-f%t to force an edit.';	;;
		warn) -warn $@;									;;
		*)    -die '%BProgrammer error%b:' 'warnOrDie is %B${warnOrDie:gs/%/%%}%b.'
	esac
} # }}}1

(( $# == 0 ))	&& -die 'Missing required argument %Ufile-name%u.'
(( $# >= 2 ))	&& -die 'Too many arguments.' "Expected one (1) %Ufile-name%u."
[[ -a $1 ]]		|| -die "No such file %B${1:gs/%/%%}%b."

typeset -- f_fullpath="$( readlink -fn -- $1 )"
[[ -n $f_fullpath ]]	|| -die 'Could not follow link.'
[[ -f $f_fullpath ]]	|| -die "%B${1:gs/%/%%}%b is %Bnot%b a file."
[[ $( /usr/bin/file -b $f_fullpath ) =~ 'text|XML' ]]	\
						|| warnOrDie "Does not seem to be a text file."

# because we've `readlink`ed the arg, it's guaranteed to have at least 
# one (1) forward slash ('/') as (and at) the root.
typeset -- f_path=${f_fullpath%/*}
typeset -- f_name=${f_fullpath:$#f_path+1}

typeset -a edit_cmd=( ${EDITOR:-$SYSLOCAL/bin/vim} $f_fullpath )

typeset -- swapinfo
swapinfo=$( :vim-swap-info $f_fullpath )
[[ -z $swapinfo || $swapinfo == <-> ]]	\
	|| -die "${swapinfo:gs/%/%%} for %B${f_name:gs/%/%%}%b."
if [[ -n $swapinfo ]]; then
	typeset -i wid=0
	wid=$( :x11-get-winid-from-pid $swapinfo )
	on_error	-die	"Being edited by process %B${swapinfo:gs/%/%%}%b,"	\
						'but no %Bwindow id%b available (1).'
	(($wid)) ||	-die	"Being edited by process %B${swapinfo:gs/%/%%}%b,"	\
						'but no %Bwindow id%b available (2).'
	typeset -i dsk=0
	dsk=$( xdotool get_desktop_for_window $wid )
	on_error	-die	"Being edited by process %B${swapinfo:gs/%/%%}%b,"	\
						"in window %B${wid:gs/%/%%}%b,"						\
						"but could not get the desktop."
	# the desktop returned by xdotool is zero (0) based, whereas evilwm 
	# uses a one (1) based keyboard shortcut system, so let's use that 
	# here.
	(( dsk++ ))
	typeset -i cur_dsktp
	cur_dsktp=$(( $( xdotool get_desktop ) + 1 ))
	typeset -a msg=()
	if (( dsk == cur_dsktp )); then
		msg=(
			"Currently being edited"
			"on %Bthis%b desktop %G(${dsk:gs/%/%%})%g,"
			"in window %S${wid:gs/%/%%}%b."
		  )
	else
		msg=(
			"Currently being edited"
			"on desktop %S${dsk:gs/%/%%}%s,"
			"in window %S${wid:gs/%/%%}%b."
			"  %GCurrent desktop is %g%S${cur_dsktp}%s%G.%g"
		  )
	fi
	(( dsk == cur_dsktp )) && highlight-window $wid &
	-die $msg
fi

typeset -- start_wd=$PWD
cd $f_path || -die "Could not %F{2}cd%f to %B${f_path:gs/%/%%}%b."

:git:current:branch 2>/dev/null | :assign repo
[[ ${repo:-:} =~ ':$' ]]|| {
	warnOrDie	\
	"This is the %B%S${${repo%:*}:gs/%/%%}%s branch%b of a %Bgit%b repo." \
	"which tracks %S${${repo#*:}:gs/%/%%}%s."
  }

typeset -- has_rcs=false
[[ -d RCS && -f RCS/$f_name,v ]] && {
	has_rcs=true
	# the `sed` bits are because RCS poorly handles these differences, 
	# but they should not ever be taken into account.
	# TODO: fix RCS
	sed -i -e '/[$]Id: /s/ '$USER' Exp '$USER' \$/ '$USER' Exp $/' ./$f_name
	rcsdiff ./$f_name
	co -l ./$f_name || -die "Could not %F{2}co -l%f %B${f_name:gs/%/%%}%b."
	sed -i -e '/[$]Id: /s/ '$USER' Exp \$/ '$USER' Exp '$USER' $/' ./$f_name
  }

# we're in the directory with $f_fullpath, SO we could just vim $f_name, 
# BUT then the vim process would not have a command including the path, 
# SO, let's use $f_fullpath
$edit_cmd

typeset -a rcsopts=( -u )

if [[ -d RCS ]]; then
	if $has_rcs; then
		$hasmsg && rcsopts+=( -m"$rcsmsg" )
		rcsdiff ./$f_name
		ci -j $rcsopts ./$f_name
	else
		# without the dash at the beginning of rcsmsg, the message would 
		# be taken from a file named in $rcsmsg
		$hasmsg && rcsopts+=( -t-"$rcsmsg" )
		ci -i $rcsopts ./$f_name
	fi
elif $hasmsg; then
	-warn 'No %SRCS/%s but you wanted to use a %Tci%t message.'
fi

cd $start_wd

# Copyright (C) 2016 by Tom Davis <tom@greyshirt.net>.
