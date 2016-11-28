#!/usr/bin/env zsh
# @(#)[:-V?26YLT;hfd6(0{QK7@: 2016/11/28 02:06:11 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. "$USR_ZSHLIB/common.zsh"

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t"
	'  '
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

typeset -r sysdata=$XDG_DATA_HOME/sysdata

function get-filetype-from-ext {
	typeset -l e=$1
	REPLY="$(
		awk -F'\t' "/^${e:gs./.\\/}\t/ {print \$2;}" $sysdata/mime.types
	)"
}

function get-handler-for-filetype {
	REPLY="$(
		awk -F'\t' "/^${1:gs./.\\/}\t/ {print \$2;}" $sysdata/mime.handlers
	)"
}

function exec-handler {
	typeset -- handler=$1
	typeset -- arg=$2
	if [[ $handler =~ '%f[[:>:]]' ]]; then
		arg=$(readlink -f $arg)
		handler=${handler:gs/%f/%s}
	fi
	typeset -a cmd=()
	for p in ${(z)handler}; do
		[[ $p =~ '%s' ]] && p="${p:gs/%s/$arg}"
		cmd+=( ${(e)p} )
	done

	nohup $cmd </dev/null >>$HOME/log/open 2>&1 &
}

function open-one-file {
	local REPLY=''

	typeset -- file=''
	typeset -- is_remote=false
	if [[ $1 =~ '^https?://' ]]; then
		is_remote=true
		file=$1
	else
		file="$(readlink -nf $1 2>/dev/null)"
		typeset -F=${1:gs/%/%%}
		[[ -n $file ]]|| { -warn "%B$F%b: No such path."; return 1; }
		[[ -a $file ]]|| { -warn "%B$F%b: No such file."; return 1; }
		[[ -f $file ]]|| { -warn "%B$F%b: Not a file.";   return 1; }
	fi

	typeset -- filetype=''
	if $is_remote; then
		REPLY='remote/web'
	elif [[ ${(U)file} =~ '^README\.M(D|ARKDOWN)$' ]]; then
		REPLY='text/markdown'
	elif [[ ${(U)file} =~ '^READ\.?ME' ]]; then
		REPLY='text/plain'
	elif [[ ${(U)file} =~ '^LICENSE' ]]; then
		REPLY='text/plain'
	elif [[ ${(U)file} =~ '^INSTALL' ]]; then
		REPLY='text/plain'
	else
		get-filetype-from-ext ${file##*.}
	fi

	if [[ -n $REPLY ]]; then
		filetype=$REPLY
	else
		filetype="$( /usr/bin/file -bi $file )"
	fi

	typeset -- filehandler=''
	get-handler-for-filetype $filetype
	if [[ -n $REPLY ]]; then
		filehandler=$REPLY
	else
		-warn "No handler for %B${filetype:gs/%/%%}%b."
		return 1
	fi

	typeset -- url=''
	if $is_remote; then
		url=${${file#http*://}%\?*}
	else
		url=${${file##*/}:gs/%/%%}
	fi

	typeset -a note=(
		"opening %B$url%b (%S${filetype:gs/%/%%}%s)"
		"with %T${filehandler:gs/%/%%}%t."
	  )

	if ((${#${(F)note}}>$COLUMNS)); then
		note[2]="    ${note[2]}"
		-notify $note
	else
		-notify "$note"
	fi
	exec-handler $filehandler $file
	on-error -warn "Could not open %B${file:gs/%/%%}%b."
}


for f in $argv; do open-one-file $f; done

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
