#!/usr/bin/env zsh
# @(#)[:!qoFKJRWTqV74SCjJrLd: 2017/06/27 04:10:37 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

emulate -L zsh
. $USR_ZSHLIB/common.zsh|| exit 86

typeset -- realbin="$(:realbin $0)"
typeset -- shortcall="${${0##*/}%.*}"
typeset -- shortbin="${${realbin##*/}%.*}"

typeset -- app=''
if [[ $shortcall != $shortbin ]]; then
	app=${shortcall#start-}
else
	# Usage {{{1
	typeset -- this_pgm=${0##*/}
	# %T/%t => terminal (green fg)
	# %S/%s => special  (magenta fg)
	typeset -a Usage=(
		"%T${this_pgm:gs/%/%%}%t %UX11-app%u"
		'  Starts an X11 app with specialized settings.'
		'  Calling as a link named %Tstart-%B%UAPP%u%b%t has the same effect'
		'   s calling %Tstart %UAPP%u%t.'
		"%T${this_pgm:gs/%/%%} -h%t"
		'  Show this help message.'
	); # }}}1
	# process -options {{{1
	function bad_programmer {	# {{{2
		-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  	};	# }}}2
	while getopts ':h' Option; do
		case $Option in
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
	(($#))|| -die 'Missing required parameter %Uapp-name%u.'
	app=$1
	shift
fi

typeset -- appbin==$app # =$appbin is the executable path
:needs $appbin xdotool
#:needs mkdir nohup ln

XDG_DOCUMENTS_DIR+=/$app
[[ -d $XDG_DATA_HOME ]]	|| mkdir -p $XDG_DATA_HOME
typeset -- appcfg=${XDG_CONFIG_HOME}/start-app/${app}.ini
[[ -d ${appcfg%/*} ]]	|| -warn 'No $XDG_CONFIG_HOME/start-app directory.'
[[ -f $appcfg ]]		|| { # create config file or exit (user decides) {{{1
	-warn "No configuration file \$XDG_CONFIG_HOME/start-app/$app.ini"
	:yes-or-no Continue || exit 1
	[[ -d ${appcfg%/*} ]]|| mkdir -p ${appcfg%/*}
	-notify "Creating configuration file \$XDG_CONFIG_HOME/start-app/$app.ini"
	cat >$appcfg <<----
		; $(:stemma-header)
		; vim: ft=dosini
		; start-app ${app} configuration

		desktop=xApp

		; all shell special characters in environment assignment will be escaped.
		; Enviroment variables are available in any following sections.
		[environment]

		; directory & file are TARGET=SOURCE where
		;   TARGET is rooted in $XDG_DATA_HOME/run/${app}, and
		;   SOURCE is rooted in $HOME
		; If there is no =SOURCE, SOURCE has the same name as TARGET.
		; !TARGET (exclamation mark, no =SOURCE) means mkdir
		;   (not available for file).
		[directory]
		[file]
		[prefix-args]
		[suffix-args]

		; $(:copyright)
	---
  } # }}}1

REALHOME=$HOME
HOME=$XDG_DATA_HOME/run/$app
[[ -d $HOME ]] || mkdir -p $HOME
cd $HOME
on-error -die "Could not %Tcd%t to %B${HOME:gs/%/%%}%b."

[[ -f .Xauthority ]]			|| ln -s ${REALHOME}/.Xauthority || -die 'Bad .Xauthority'
[[ -d rxfer ]]					|| ln -s ${REALHOME}/rxfer

typeset -- docspath=${XDG_DATA_HOME}/$app
[[ -d $docspath ]]&&
	{ [[ -d docs ]]|| ln -s $docspath docs }

function badcfg { # {{{1
	[[ $appcfg == ${XDG_CONFIG_HOME}/* ]]&& appcfg=\$XDG_CONFIG_HOME${appcfg#$XDG_CONFIG_HOME}
	[[ $appcfg == ${HOME}/* ]]&& appcfg=\$HOME${appcfg#$HOME}
	-die $@ "file: %S${appcfg:gs/%/%%}%s" "line $LNO: %T$ln%t"
} # }}}1
integer desktop=0
function optcmd-general { # {{{1
	case $1 in
		desktop)	eval "desktop=\$dsk${(U)2:-}";	;;
		*)			badcfg "Unknown configuration directive:" $1=$2
	esac
} # }}}1
function optcmd-fsobject { # {{{1
	typeset -- TRG=${HOME}/${1} t=-${3:0:1} fsType=$3
	[ $t $TRG ]&& return 0
	[[ -e $TRG ]]&& badcfg "%B${1:gs/%/%%}%b exists but is not a $fsType."

	[[ $TRG == \!* ]]&& {
		[[ $t == '-d' ]]|| badcfg 'Only directories can be created.'
		mkdir -p $HOME/${TRG:1}
		return $?
	  }

	typeset -- SRC="$(readlink -f ${REALHOME}/$2)"
	[[ -n $SRC ]]|| return 1

	if [ $t $SRC ]; then
		if [[ $SRC == ${REALHOME}/.* ]]; then
			-warn "Moving %B${2:gs/%/%%}%b from %S\$HOME%s to %S\$XDG_DATA_HOME/run/${app:gs/%/%%}%s."
			mv $SRC $TRG
		else
			ln -s $SRC $TRG ||
				badcfg "Could not link %B${2:gs/%/%%}%b to %B${1:gs/%/%%}%b."
		fi
	elif [[ -e $SRC ]]; then
		badcfg "%B${1:gs/%/%%}%b exists but is not a $fsType."
	fi
} # }}}1
typeset -a prefixArgs=()
function optcmd-prefix-args { prefixArgs+=( "${1}${2:+=$2}" ); }
typeset -a suffixArgs=()
function optcmd-suffix-args { suffixArgs+=( "${1}${2:+=$2}" ); }
function optcmd-directory { optcmd-fsobject $1 ${2:-$1} directory; }
function optcmd-file { optcmd-fsobject $1 ${2:-$1} file; }
function optcmd-environment { # {{{1
	(($#==2))||
		badcfg 'Bad environment variable declaration.'
	[[ $1 == ${(q)1} ]]||
		badcfg "Bad environment variable name %B${2:gs/%/%%}%b."
	eval "export $1=${(q)2}"||
		badcfg "Could not export %B$1%b as %B'${2:gs/%/%%}%b'."
	[[ $2 == ${(P)1} ]]||
		badcfg "Could not use %B'${(q)2:gs/%/%%}%b' as a value."
	[[ ${(Pt)1} == scalar-export ]]||
		badcfg "Could not export %B'${1:gs/%/%%}%b'."
} # }}}1


[[ -f $appcfg ]]&& {
	typeset -- docmd='general'
	typeset -a validcmds=(
		general directory file environment prefix-args suffix-args
	  )
	integer LNO=0
	for ln in ${(f)"$(<$appcfg)"}; do
		((LNO++))
		# COMMENTS & BLANK LINES
		[[ $ln == \;* ]]&& continue
		[[ $ln == \#* ]]&& continue
		[[ $ln =~ '^[[:blank:]]$' ]]&& continue
		# HEADING
		[[ $ln =~ '\[(.*)\]' ]]&& {
			docmd=$match[1]
			((${validcmds[(I)$docmd]}))||
				badcfg 'Unknown category in ini file.'
			continue
		  }
		# SETTING
		[[ $ln =~ '([^=]+)(?:=(.*))?$' ]]&& {
			optcmd-$docmd $match
			continue
		  }
		badcfg "Unknown configuration directive."
	done
  }

((desktop))&&
	xdotool set_desktop $desktop
nohup $appbin $prefixArgs $@ $suffixArgs > log 2>&1 &!

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
