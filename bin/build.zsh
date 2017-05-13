#!/usr/bin/env zsh
# @(#)[:ZNzBFFtwmnw3a2f60Uv4: 2017/05/13 00:56:26 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

emulate -L zsh
. $USR_ZSHLIB/common.zsh|| exit 86

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

typeset -- rx_sets_outfile=$'(^|[ \t])-[co][[:>:]]'
typeset -- bofile='build.output'
typeset -i totalerrs=0
typeset -- XFILE=''

print build $*  > $bofile
print '----'   >> $bofile

function file:exists { # {{{1
	[[ -f $1 ]]&& return 0
	-warn "File not found: %S${1:gs/%/%%}%s, %F{1}Skipping%f."
	return 1
} # }}}1
function file:readable { # {{{1
	[[ -r $1 ]]&& return 0
	-warn "File %S${1:gs/%/%%}%s is unreadable, %F{1}Skipping%f."
	return 1
} # }}}1
function parse-warn { # {{{1
	typeset -a msg=(
		'Syntax Error, '$1
		"Line %S$3%s, %S${2:gs/%/%%}%s."
	  )
	[[ -n $4 ]]&& msg+=( "> %F{4}${4:gs/%/%%}%f <" )
	-warn $msg
} # }}}1

function __nasm { REPLY="$2 $1"; }
function __ld { REPLY="$2 ${1%.*}.o"; }
function __CC { # {{{1
	typeset -- sname=${XFILE:-$1}
	typeset -- bname=${sname%.*}
	typeset -- cc=${2[(w)1]}
	typeset -- cc_opts=${2[(w)2,-1]}

	typeset -- outopt=''
	[[ $cmd =~ $rx_sets_outfile ]] || outopt="-o '$bname' "

	typeset -- ALL='all'
	[[ $cc == clang ]]&& ALL='everything'

	REPLY="$cc -W$ALL $outopt'$sname' $cc_opts"
} # }}}1
function __clang { __CC $@; }
function __gcc { __CC $@; }
function __ragel { # {{{1
	typeset -- bname=${1%.*} oext=c outopt=''
	typeset -- cmd=$2
	if [[ $cmd =~ '-o ([^ \t]+)' ]]; then
		XFILE=$match
	else
		[[ $cmd =~ '-([CDJZR])\b' ]]&& {
			case $match in
				C) oext=c;		;;
				D) oext=d;		;;
				J) oext=java;	;;
				Z) oext=go;		;;
				R) oext=rb;		;;
			esac
		  }
		[[ $1 =~ '.rh$' ]]&& oext=h
		XFILE=${${1%.*}##*/}.$oext
		outopt="-o $XFILE"
	fi
	REPLY="$cmd $outopt $1"
  } # }}}1


function build-one { # {{{1
	file:exists $1		|| return 1
	file:readable $1	|| return 1

	# the +t turns off printing of variables which are already set
	typeset +t -- SRC ln utest uflags uresp commented
	typeset -- buildopts=()
	typeset -i I=0
	typeset -- headerfound=false
	typeset -- fhead=${1%.*}
	typeset -- fbase=${fhead##*/}

	# PARSE HEADER {{{2
	exec {SRC}<$1
	while read -ru $SRC ln; do
		I=$((I+1))
		[[ $ln =~ '^[ \t]$' ]]&& { -warn "No %BBUILD-OPTS%b in %S${1:gs/%/%%}%s."; return 1; }
		[[ $ln =~ 'BUILD-OPTS' ]]&& { headerfound=true; break; }
	done
	$headerfound || { -warn "No %BBUILD-OPTS%b in %S${1:gs/%/%%}%s."; return 1; }
	buildopts+=( ${ln:$MBEGIN-1} )
	while read -ru $SRC ln; do
		I=$((I+1))
		commented=false
		[[ $ln =~ '^[ \t]$' ]]&& break
		[[ $ln =~ '---' ]]&& break
		[[ $ln =~ 'BUILD-OPTS' ]]&& {
			buildopts+=( ${ln:$MBEGIN-1} )
			continue
		}
		[[ $ln =~ '#' ]]&& {
			ln=${ln:$MEND}
			commented=true
		}
		[[ $ln =~ ':' ]]|| {
			$commented || parse-warn 'not a directive (no %S:%s).' $1 $I $ln
			continue
		}
		ln=${ln:$MEND}
		[[ $ln =~ ':' ]]&& {
			utest=${ln:0:$MBEGIN-1}
			ln=${ln:$MEND}
			[[ $utest =~ '=' ]]|| {
				parse-warn 'no %S=%s in %Tuname%t test.' $1 $I
				return 1
			}
			uflags=${utest:0:$MBEGIN-1}
			uresp=${utest:$MEND}
			[[ $uresp =~ $(uname -$uflags) ]]|| continue
		}
		buildopts+=( $ln )
	done
	exec {SRC}>&-
	# }}}2
	# BUILD-OPTS TO SHELL COMMANDS {{{2
	typeset -a cmds=()
	typeset -- cmd=''
	for c in $buildopts; do
		[[ $c =~ '^BUILD-OPTS' ]]&& {
			[[ -n $cmd ]]&& cmds+=( $cmd )
			if [[ $c =~ '^BUILD-OPTS[ \t]*\(([^\)]+)\)' ]]; then
				cmd=$match
			else
				cmd=$CC
			fi
			continue
		}
		[[ $c =~ '^[ \t]*(.*?)[ \t]*$' ]] # strip leading+trailing ws
		[[ -n $match ]]&& cmd+=" $match"
	done
	cmds+=( $cmd )
	# }}}2
	# TWEAK AND RUN COMMANDS {{{2
	typeset -i i=1
	while ((i<=$#cmds)); do
		cmd=$cmds[i++]
		((${+functions[__${cmd[(w)1]##*/}]}))&& {
			__${cmd[(w)1]##*/} $1 $cmd
			cmd=$REPLY
		  }
		$verbose && echo "$cmd" | fold -sw $(tput columns) >&2
		$actually_run_cmd || continue
		eval "$cmd" 2>&1 | fold -sw 80 | tee -a "$bofile"
		(($pipestatus[1]))&& {
			-warn "${1:gs/%/%%} build failed"
			return 1
		  }
	done
	# }}}2
	return 0
} # }}}1

(($#))|| -die 'No source file(s) given.'

for sourcefile in $@; do
	build-one $sourcefile
	(( totalerrs += $? ))
done

typeset -i LINES=$(tput lines)
if (( $((LINES-2)) <= $(wc -l < $bofile) )); then
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
