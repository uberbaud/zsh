#!/usr/bin/env zsh
# @(#)[:ZNzBFFtwmnw3a2f60Uv4: 2016/11/13 02:32:52 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

emulate -L zsh
. $USR_ZSHLIB/common.zsh

# Usage {{{1
typeset -- this_pgm=$(basename $0)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t"
	'  Uses information in a header to get build options and does it.'
	'    %T-v%t  verbose'
	'    %T-n%t  dry run and verbose'
	"%T${this_pgm:gs/%/%%} -H%t"
	'  Show an extensive description of the %Bbuild header%b.'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
function -filedoc { # {{{1
	typeset -- tag='IN-FILE-DOCUMENTATION'
	sed -e "1,/^: <<-$tag/d" -e "/^$tag/"$'{g\nq\n}' $1 | less -r
    exit
} # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
typeset -- verbose=false
typeset -- actually_run_cmd=true
while getopts ':hHnv' Option; do
	case $Option in
		h)	-usage $Usage;										;;
		H)	-filedoc $0;										;;
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

# begin in-file documentation {{{1
: <<-IN-FILE-DOCUMENTATION

    [1mEXTENSIVE BUILD HEADER DESCRIPTION[22m

    The build header must occur before the first blank line in the file.

    In order to support various comment styles, each header declaration 
    line may contain any number of characters before the declaration
    and looks like:

[33m
        BUILD-OPTS (clang)
        : -opt
        # some comment
        :s=Linux: --linux-option
        :s=Darwin:---some-text
        : --darwin-option1
        : --darwin-option2
        :---some-text
        ---
[0m
    The compiler/assembler/etc name is in parenthesis after the
    term BUILD-OPTS and more than BUILD-OPTS declaration
    is allowed, each one run in turn.

    The first triple dash ends the build header.
    each :flag=SomeText: is a uname flag set, if the text matches

IN-FILE-DOCUMENTATION
# end in-file documentation }}}1

# Copyright (C) 2016 by Tom Davis <tom@greyshirt.net>.
