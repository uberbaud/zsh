#!/usr/bin/env zsh
# $Id: start-surf.zsh,v 1.3 2016/09/28 03:44:56 tw Exp $
# vim: tabstop=4 textwidth=72 noexpandtab ft=zsh

emulate -L zsh
. $USR_ZSHLIB/common.zsh

typeset -r homepage=$XDG_DATA_HOME/twSite/homepage.html
typeset -- runpath
mktemp -d $XDG_DATA_HOME/run/surf/sXXXXXXX		\
	| :assign runpath							\
					|| -die 'Could not create %Srunpath%s.'
cd $runpath			|| -die "Could not cd to %S${runpath:gs/%/%%}%s."

# Usage {{{1
typeset -- thisPgm=${0##*/}
typeset -a Usage=(
	"%T${thisPgm:gs/%/%%}%t [%T-c%t] [%Surl%s]"
	'  Opens the %Surl%s or %Shomepage%s if no %Surl%s is given.'
	'  -c  Creates a copy to open.'
	"%T${thisPgm:gs/%/%%}%t -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad-programmer { #{{{2
	-die '%BProgrammer error%b:' "No %Tgetopts%t action defined for %T-$1%t."
  };	#}}}2
typeset -- useACopy=false
while getopts ':hc' Option; do
	case $Option in
		c)	useACopy=true;												;;
		h)	-usage $Usage;												;;
		\?)	-die "Invalid option: %S-${OPTARG:gs/%/%%}%s'.";			;;
		\:)	-die "Option %S-${OPTARG:gs/%/%%}%s requires an argument.";	;;
		*)	bad-programmer $Option;										;;
	esac
done
unset -f bad-programmer
shift $(($OPTIND - 1))	; # ready to process non '-' prefixed arguments
(($#<2))|| -die 'Can only load one URL at a time.' $Usage
# /options }}}1

typeset -- URL=${1:-$homepage}

function run {
	# we're taking it offline, yo!
	$useACopy && {
		typeset -- F=${URL#file://}
		[[ -f $F ]]|| -die "Not a file: %S${URL:gs/%/%%}%s."
		F=$( readlink -nf $F )
		
	}

	$SYSLOCAL/bin/surf -x $URL

	rmdir "$runpath"
}

run &

# Copyright (C) 2010 by Tom Davis <tom@tbdavis.com>.
