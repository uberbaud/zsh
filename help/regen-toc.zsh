#!/usr/bin/env zsh
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. "$USR_ZSHLIB/common.zsh"

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

typeset -a usrhelp=()
typeset -a syshelp=()
for p in ${(ps.:.)HELPPATH}; do
	if [[ $p =~ '^/home/' ]]; then
		usrhelp+=( $p )
	else
		syshelp+=( $p )
	fi
done

function mk-subtoc-for-paths {
	for p in $argv; do print -l $p/*(:t); done		\
	| egrep -v 'TOC|\.zsh$'							\
	| sort											\
	| column -xc 72									\
	| sed 's/^/        /'
}

typeset -a usrhelptoc=(${(f)"$( mk-subtoc-for-paths $usrhelp )"})
typeset -a syshelptoc=(${(f)"$( mk-subtoc-for-paths $syshelp )"})

# open the file
exec 3>${usrhelp[1]}/TOC

# header
print -Pu 3  '%BZSH Help Table of Contents%b'
print -Plu 3 '' '        Use %Bhelp %Utopic%u%b.'
# user provided files
print -Plu 3 '' '%BUser Help Topics%b'
print -Plu 3 $usrhelptoc
# system provided files
print -Plu 3 '' '%BSystem Help Topics%b'
print -Plu 3 $syshelptoc

# close the file
exec 3>&-

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
