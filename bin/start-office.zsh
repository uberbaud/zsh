#!/usr/bin/env zsh
# @(#)[:!qoFKJRWTqV74SCjJrLd: 2017/05/18 20:56:42 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

emulate -L zsh
. $USR_ZSHLIB/common.zsh|| exit 86

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

typeset -- app=soffice
typeset -- appbin=$SYSLOCAL/bin/$app
:needs $appbin xdotool
#:needs mkdir nohup ln

HOME=$XDG_DATA_HOME/run/$app
[[ -d $HOME ]] || mkdir -p $HOME
cd $HOME
on-error -die "Could not %Tcd%t to %B${HOME:gs/%/%%}%b."

[[ -f .Xauthority ]]	|| ln -s /home/tw/.Xauthority || -die 'Bad .Xauthority'
[[ -d rxfer ]]			|| ln -s /home/tw/rxfer
[[ -d docs ]]			|| ln -s /home/tw/docs/soffice

xdotool set_desktop ${dskFULLSCREEN:-6}
nohup $appbin $@ > log 2>&1 &!

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
