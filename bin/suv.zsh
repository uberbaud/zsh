#!/usr/bin/env zsh
# $Id: suv.zsh,v 1.13 2016/10/23 22:46:20 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

emulate -L zsh
. "$USR_ZSHLIB/common.zsh"

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [%T-f%t] %Ufile name%u"
	'  Safely edits a file requiring super user privileges to do so.'
	'  It copies the file, edits it, and %Tsu mv%ts it.'
	'  %T-f%t  Force the edit, even if %Tv%t seems a better match.'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
typeset -- warnOrDie='-die'
while getopts ':hf' Option; do
	case $Option in
		h)	-usage $Usage;										;;
		f)	warnOrDie='-warn';									;;
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

(( $# == 0 )) && -die 'Missing expected parameter %Ufile name%u.'
(( $# > 1 ))  && -die 'Too many arguments. Expected one (1) %Ufile name%u.'

typeset -r realname=$(readlink -fn $1)
[[ -n $realname ]]|| -die 'Could not get actual file name (bad link?).'
[[ -a $realname ]]|| -die "%B${realname:gs/%/%%}%b does %Bnot%b exist."
[[ -f $realname ]]|| -die "%B${realname:gs/%/%%}%b is %Bnot%b a regular file."
typeset -- barefile=${realname##*/}

[[ -r $realname && -w $realname:h && -d ${realname:h}/RCS ]]&& {
	$warnOrDie "%S${barefile:gs/%/%%}%s is RW, maybe use %Tv%t?" \
		"Use %T${this_pgm:gs/%/%%} -f %U${1:gs/%/%%}%u%t to edit anyway."
}


typeset -- tempdir
mktemp -d	|:assign tempdir
on-error -die 'Could create a temporary working directory.'

function cleanup { rm -rf $tempdir; }
function asRoot-obsd { #{{{1
	for i in {1..3}; do
		errstr=$( doas $@ 3>&1 1>&2 2>&3 3>&- )
		[[ $errstr == 'doas: Operation not permitted' ]] || break
		-warn 'Sorry, try again.'
	done
	[[ -z $errstr ]] && return 0
	-die ${errstr:gs/%/%%}
} #}}}1
typeset -- asRoot
case $(uname) in
	OpenBSD)	asRoot=asRoot-obsd;		;;
	Linux)		asRoot=sudo;				;;
	*)			-die "Can't handle OS => %S${$(uname):gs/%/%%}%s."
esac

if [[ -r $realname ]]; then
	alias Install=install
else
	alias Install=$asRoot\ install
fi

-notify 'Copying file to temporary directory'
Install -o $(id -un) -g $(id -gn) -m 0600 $realname $tempdir/$barefile
on_error -die "Could not copy ${realname:gs/%/%%}."

# make a copy so we can compare to see if we need to copy it back
cp $tempdir/$barefile{,.orig}

${EDITOR:-vim} $tempdir/$barefile

diff $tempdir/$barefile{,.orig}
(($?))|| {
	-warn 'File unchanged. Doing nothing.'
	cleanup
	exit 0
  }

if [[ -w $realname ]]; then
	alias Install=install
else
	alias Install=$asRoot\ install
fi

-notify 'Copying temp file back to original.'
typeset -a fATTR=()
case $(uname) in
	OpenBSD)
		fATTR=( $( stat -f '-m %p -o %u -g %g' $realname ) )
		fATTR[2]=${fATTR[2][-4,-1]} # 100700 -> 0700
		;;
	Linux)
		fATTR=( $( stat -c '-m %a -o %u -g %g' $realname ) )
		;;
	*)
esac
Install $fATTR $tempdir/$barefile $realname

typeset -- hold=$HOME/hold/$( uname -r )/sys_files${realname%/*}
-notify "Saving a copy in %S${hold:gs/%/%%}%s."
[[ -d $hold/RCS ]]|| mkdir -p $hold/RCS

if cd $hold; then
	if [[ -f $hold/RCS/$barefile,v ]]; then
		co -l $barefile
	else
		-notify 'Creating an initial %BRCS checkin%b of unedited version.'
		cp $tempdir/$barefile.orig $barefile
		ci -i -t"-original $realname" $barefile
		co -l $barefile
	fi
	cp $tempdir/$barefile $barefile
	on-error -warn "Could not save a copy to %S${hold:gs/%/%%}%s."
	ci -j -u $barefile
else
	-warn "Could not %Tcd%t to %S${hold:gs/%/%%}%s."
fi

cleanup

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
