#!/usr/bin/env zsh
# @(#)[:T}fx;N6;{V;iE4tyIG3%: 2017/03/05 06:20:25 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

emulate -L zsh
. $USR_ZSHLIB/common.zsh|| exit 86

# Usage {{{1
typeset -- this_pgm=${0##*/}
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [[%T-t%t] %Surl%s]"
	'  opens the url (if any).'
	'  %T-t%t The url is a temporary file, so make a copy.'
	'      Each temporary file must be preceded by %T-t%t.'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
typeset -a tempFiles=()
while getopts ':ht:' Option; do
	case $Option in
		h)	-usage $Usage;										;;
		t)	tempFiles+=( $OPTARG );								;;
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

typeset -- app=firefox

HOME=$XDG_DATA_HOME/run/$app
[[ -d $HOME ]] || mkdir /bin/mkdir -p $HOME
cd $HOME
on_error -die "Could not %Tcd%t to %B${HOME:gs/%/%%}%b."

[[ -d .mozilla ]]		|| ln -s $XDG_CONFIG_HOME/mozilla .mozilla
[[ -f .Xauthority ]]	|| ln -s /home/tw/.Xauthority || -die 'Bad .Xauthority'
[[ -d rxfer ]]			|| ln -s /home/tw/rxfer
[[ -d hold ]]			|| mkdir hold

for t in $tempFiles; do
	F=${t#file://}
	[[ -f $F ]]|| {
		-warn 'Could not find file %S${F:gs/%/%%}%s.'
		continue
	  }
	H=$HOME/hold/${F:gs/\//:}
	ln $F $H || cp $F $H || {
		-warn 'Could not save a file ${F:gs/%/%%}%s.'
		continue
	  }
	argv+=( file://$H )
done

/usr/bin/nohup $SYSLOCAL/bin/$app $argv > log 2>&1 &

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
