#!/usr/bin/env zsh
# $Id: todo.zsh,v 1.8 2016/10/25 07:09:12 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh

# Usage {{{1
typeset -- this_pgm=${0##*/}
typeset -a Usage=(
	'%T${this_pgm:gs/%/%%}%t [%T-l%t|%T-h%t|%T-e%t|[%T--%t] %Utodo item%u]'
	'  Adds %Utodo item%u to %Btodo.lst%b'
	'  With no parameters, accepts a new todo item from %Bstdin%b.'
	'  Otherwise,'
	'    %T-e%t  %BEdit%b %Btodo.lst%b in %S$EDITOR%s.'
	'    %T-h%t  Show this %Bhelp%b message.'
	'    %T-l%t  %BList%b contents of %Btodo.lst%b.'
  ) # }}}1

typeset -- list=$XDG_DATA_HOME/sysdata/todo.lst

function add_item {
		date +"%Y-%m-%d %H:%M:%S %Z" | tr -d '\n'
		awk '{print "    " $0;}'
	} >> $list

if (( $# == 0 )); then
	-notify '%B^D%b %F{3}to exit.%f'
	typeset -- item=$(mktemp)
	trap "rm '$item'" EXIT INT
	cat > $item
	# exit if we didn't actually add anything
	[[ -s $item ]] || -die 'Did nothing.'
	(( $(tr -d '[[:space:]]' <$item | wc -c) )) || -die 'Nothing but space.'
	add_item < $item
elif [[ $1 == '-l' ]]; then
	[[ -s $list ]] && { cat $list; exit 0  }
	-die 'No %Btodo.lst%b.'
elif [[ $1 == '-e' ]]; then
	$EDITOR $list
elif [[ $1 == '-h' ]]; then
	-usage $Usage
elif [[ $1 == -- ]]; then
	shift
	add_item <<< $*
elif [[ $1 == -* ]]; then
	-die 'Unknown parameter'
else
	add_item <<< $*
fi

:up-conky-note

# Copyright (C) 2016 by Tom Davis <tom@greyshirt.net>.
