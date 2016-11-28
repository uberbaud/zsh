#!/usr/bin/env zsh
# @(#)[:GpEYZa*c{{hMx~)jN6Sk: 2016/11/19 05:10:44 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

. $USR_ZSHLIB/common.zsh

[[ -d $LOCALBIN ]] || -die '%F{6}$LOCALBIN%f is not set.'
path+=( $LOCALBIN )

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [%T-m%t %Umessage%u] [%T-f%t] %Ufile%u"
	'  %T-m%t  Use %Umessage%u as rcs checkin message.'
	'  %T-s%t  Create new stemma and replace any existing.'
	"  %T-f%t  Force edit even if %Ufile%u isn't text."
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
typeset -- hasmsg=false;
typeset -- newStemma=false
typeset -- warnOrDie='die';
typeset -- rcsmsg='';
while getopts ':fshm:' Option; do
	case $Option in
		f)	warnOrDie='warn';									;;
		s)	newStemma=true;										;;
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

typeset -- f_fullpath
if [[ -x $USRBIN/getTrueName ]]; then
	f_fullpath="$( $USRBIN/getTrueName $1 )"
else
	f_fullpath="$( readlink -fn -- $1 )"
fi


[[ -n $f_fullpath ]]	|| -die 'Could not follow link.'
[[ -f $f_fullpath ]]	|| -die "%B${1:gs/%/%%}%b is %Bnot%b a file."
[[ $( /usr/bin/file -b $f_fullpath ) =~ 'text|XML' ]]	\
						|| warnOrDie "Does not seem to be a text file."

# because we've `readlink`ed the arg, it's guaranteed to have at least 
# one (1) forward slash ('/') as (and at) the root.
typeset -- f_path=${f_fullpath%/*}
typeset -- f_name=${f_fullpath:$#f_path+1}

# we're in the directory with $f_fullpath, SO we could just vim $f_name, 
# BUT then the vim process would not have a command including the path, 
# SO, let's use $f_fullpath
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
	rcsdiff ./$f_name
	co -l ./$f_name || -die "Could not %F{2}co -l%f %B${f_name:gs/%/%%}%b."
  }

# different OSes have different ways of getting the sha384, and of 
# providing that in base64, additionally
# macOS sed requires an "unattached" parameter for -i (eg none => `-i 
# ''`), whereas linux and openbsd require an "attached" parameter (eg 
# none => `-i`).
typeset -a inplace=( -i )
if [[ $(uname) == Darwin ]]; then
	shaid() { echo ${$(shasum -a 384 ./$1)[1]} | xxd -r -p | base64; }
	inplace+=( '' )
elif [[ $(uname) == Linux ]]; then
	shaid() { echo ${$(sha384sum ./$1)[1]} | xxd -r -p | base64; }
else
	shaid() { cksum -a sha384b ./$1; }
fi

typeset -- stemma=''
typeset -- scmd='/@(#)/{ s/^[^)]*)//p;q;}'; scmd=${scmd//;/$'\n'}
if [[ $(sed -n -e $scmd ./$f_name ) =~ '\[:([[:print:]]+): ' ]]; then
	stemma=$match[1]
	if (( $#stemma != 20 )); then
		stemma=$(uuid85|tr '>' , )
		printf '  \e[36m1. stemma reset to %s\e[0m\n' $stemma >&2
		newStemma=true
	elif $newStemma; then
		typeset -- old=$stemma
		stemma=$(uuid85|tr '>' , )
		printf '  \e[36m1. stemma reset from %s to %s\e[0m\n' $old $stemma >&2
		unset old
	else
		printf '  \e[36m1. stemma set to %s\e[0m\n' $stemma >&2
	fi
elif $newStemma; then
	-warn 'No %Bstemma%b found, so not resetting one.'
fi

# TEMPORARY !!! Note the superfluous quotes to keep egrep from matching 
# any of the `egrep` or `sed` lines
typeset -a now=( $(date -u +'%Y/%m/%d %H:%M:%S') )
typeset -- newid
egrep -q '\$Id'': ' ./$f_name && { # previously checked in
	-warn 'Updating %SRCS:Id%s line.'

	[[ -n $stemma ]]|| {
		stemma=$(uuid85|tr '>' , )
		printf '  \e[36m2. stemma set to %s\e[0m\n' $stemma >&2
	}
	printf ':%s: %s %s %s@%s' $stemma $now $USERNAME $HOST	\
		| sed -e 's#[_&\\]#\&#g'							\
		| :assign newid
	sed "${(@)inplace}" -E '/@\(#\)/s_\[[^\]*\]_['$newid']_' ./$f_name
	sed "${(@)inplace}" -E '/\$Id:[^$]+\$/s__@''(#)['$newid']_' ./$f_name
}
egrep -q '\$Id''\$' ./$f_name && { # never been kissed
	-warn 'Updating (empty) %SRCS:Id%s line.'
	[[ -n $stemma ]]|| {
		stemma=$(uuid85|tr '>' , )
		printf '  \e[36m3. stemma set to %s\e[0m\n' $stemma >&2
	}
	printf ':%s: %s %s %s@%s' $stemma $now $USERNAME $HOST	\
		| sed -e 's#[_&\\]#\&#g'							\
		| :assign newid
	sed "${(@)inplace}" -E '/\$Id\$/s__@''(#)['$newid']_' ./$f_name
}
# END OF TEMPORARY

typeset -- CKSUM=$(shaid $f_name)

# do the CKSUM before this to force a save
$newStemma && {
	-warn 'Updating current file with new stemma.'
	printf ':%s: %s %s %s@%s' $stemma $now $USERNAME $HOST	\
		| sed -e 's#[_&\\]#\&#g'							\
		| :assign newid
	sed "${(@)inplace}" -e '/@''(#)/s_\[[^\]*\]_['$newid']_' ./$f_name
}

$edit_cmd


# UPDATE the @''(#)[…] string
# 1. If there is such a string, and
egrep -q '@''\(#\)\[' ./$f_name && {
	# 2. if there were changes
	[[ $CKSUM == $(shaid $f_name) ]]|| {
		now=( $(date -u +'%Y/%m/%d %H:%M:%S') )
		[[ -n $stemma ]]|| {
			stemma=$(uuid85|tr '>' ',' )
			printf '  \e[36m4. stemma set to %s\e[0m\n' $stemma >&2
		}
		# escape any of separator _, whole match &, or escape \
		printf ':%s: %s %s %s@%s' $stemma $now $USERNAME $HOST	\
			| sed -e 's#[_&\\]#\&#g'							\
			| :assign newid
		sed "${(@)inplace}" -e '/@''(#)/s_\[[^\]*\]_['$newid']_' ./$f_name
	}
}

if [[ -d RCS ]]; then
	typeset -a rcsopts=( -u )
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
