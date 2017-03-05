# @(#)[:y%se23,6f2|WqGFX-9?g: 2017/03/05 06:08:24 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

CLICOLOR=1

function h1 { # prints a header with appropriate attributes {{{1
	if [[ -t 1 ]]; then
		printf "\e[1;44;37m%${COLUMNS}s\r ─ %s ─\e[0m\n" '' "$1"
	else
		printf "===[[ %s ]]===  \n" "$1"
	fi
}	; # }}}1
function ruler { # prints a ruler the width of the term {{{1
	typeset -- dots='....+....'
	typeset -i count=$COLUMNS
	[[ -n $1 ]] && count="$1"
	(( $count < 1 )) && {
		die "syntax: ruler count"		\
			"%Ucount%u must be a  positive integer. Found %B$1%b."
	  }

	declare -- Ruler=''
	declare -i tens=$(( count / 10 ))
	declare -i ones=$(( count - (tens * 10) ))
	for (( i=1; i<=$tens; i++)); do
		dial=${i: -1}
		Ruler+="${dots}$dial"
	done
	Ruler+="${dots:0:$ones}"
	# add some color *only* if we're writing to a terminal
	[ -t 1 ] && Ruler="[0;47;36m${Ruler}[0m"
	# pipe anything that's coming in on stdin
	if [ -t 0 ]; then
		print $Ruler
	else
		print $Ruler
		cat
		print $Ruler
	fi
}; #}}}1

export CLICOLOR
export INPUTRC=$XDG_CONFIG_HOME/init/input.rc


# Copyright © 2015,2016 by Tom Davis <tom@greyshirt.net>.
