#!/usr/bin/env zsh
# $Id: build.zsh,v 1.12 2016/10/23 20:37:59 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

emulate -L zsh
. $USR_ZSHLIB/common.zsh

# Usage {{{1
typeset -- this_pgm=$(basename $0)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t"
	'  %T-v%t  verbose'
	'  %T-n%t  dry run and verbose'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
typeset -- verbose=false
typeset -- actually_run_cmd=true
while getopts ':hnv' Option; do
	case $Option in
		h)	-usage $Usage;										;;
		n)	verbose=true; actually_run_cmd=false;				;;
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
typeset -a AWKPGM=( # {{{1
	'BEGIN'	'{ inside = 0; }'
	# START OF BUILD-OPTS
	'/^[[:space:]]*\/?\*[[:space:]]+BUILD-OPTS[[:space:]]*$/'
		'{ inside = 1; next; }'
	# an actual build option
	'inside == 1 && /:/'
		'{ printf( " %s", $2 ); }'
	# FOUND END OF BUILD-OPTS
	'/^[[:space:]]*\*[[:space:]]+---[[:space:]]*$/'
		'{ nextfile; }'	# quit
  ) # }}}1
typeset -- rx_sets_outfile=$'(^|[ \t])-[co][[:>:]]'
typeset -- bofile='build.output'
typeset -i totalerrs=0

print build $*  > $bofile
print '----'   >> $bofile

function build_one {
	-notify "Building for %B${1:gs/%/%%}%b."
	echo "--- $1" >> $bofile
	typeset -- base="${1%.c}"
	typeset -- source="${base}.c"
	[[ -f "$source" ]] || {
		echo "!!! no such file $source" >> $bofile
		-warn "Could not find %Ufile%u %B${source:gs/%/%%}%b."
		return 1
	}

	typeset -- cc_opts=$( awk -F':[[:space:]]*' "$AWKPGM" $source )
	on_error {
		echo "!!! no BUILD-OPTS for $source" >> $bofile
		-warn 'Could not get BUILD-OPTS'
		return 1
		}

	typeset -- outopt=''
	[[ $cc_opts =~ $rx_sets_outfile ]] || outopt="-o '$base'"

	typeset -- cmd="clang -Wall $outopt '$source' $cc_opts"
	$verbose && echo "$cmd" | fold -sw $(tput columns) >&2
	$actually_run_cmd || return 0
	eval "$cmd" 2>&1 | fold -sw 80 | tee -a "$bofile"
	(($pipestatus[1]))&& {
		-warn "${base:gs/%/%%} build failed"
		return 1
	  }
	return 0
}

(($#))|| {
	# it's easy to set an array using a glob, so we do that, but there's 
	# only one item, so it otherwise handles pretty much like a simple 
	# scalar.
	typeset -- srcfile=( *.c(om[1]) )
	-warn 'No source file given' "Using %B%U${srcfile:gs/%/%%}%u%b."
	set $srcfile
}

for sourcefile in $@; do
	build_one $sourcefile
	(( totalerrs += $? ))
done

typeset -i LINES=$(tput lines)
if (( $(wc -l < $bofile) >= $((LINES - 2)) )); then
	clear
	less $bofile
else
	# we have the output already
	rm $bofile
fi
exit totalerrs

# Copyright (C) 2016 by Tom Davis <tom@greyshirt.net>.
