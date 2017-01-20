#!/usr/bin/env zsh
# @(#)[:DOJopgjq@V8T3(fNoa#V: 2017/01/20 04:07:24 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh || exit 86
zmodload zsh/mathfunc || exit 86

typeset -i   -- hue=0 cbc=5

function reqFloat {
	[[ $3 =~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)([eE][0-9]+)?$' ]]|| {
		-die "Option %S-$1%s (%B$2%b) is not a valid %Bfloat%b."
	  }
	typeset -g $2=$3
}
function reqInt {
	[[ $3 == <-> ]]|| {
		-die "Option %S-$1%s (%B$2%b) is not a valid %Binteger%b."
	  }
	typeset -g $2=$3
}

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [%Uinfile%u %U…%u]"
	'  Rainbowify input.'
	'    -u  Hue (0 → 30) %B0%b, the default, means random.'
	"    -c  Characters per color. The default is %B${cbc}%b."
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
while getopts ':c:u:h' Option; do
	case $Option in
		c)	reqInt $Option cbc $OPTARG;							;;
		u)	reqInt $Option hue $OPTARG;							;;
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

((cpc>0))&&		-die '%Schars per color%s must be greater than %B0%b.'
((hue<0))&&		-die '%Shue%s must be between %B0%b and %B30%b (incl).'
((hue>30))&&	-die '%Shue%s must be between %B0%b and %B30%b (incl).'

typeset -r reANSI=$'\e''\[[0-9]+(;[0-9]+)*[mK]'
typeset -a colors=(
	57    91   162   196   172   106    82    41    37    26
	56   127   161   202   136   112    46    42    31    27
	92   126   197   166   142    76    47    36    32    21
  )

function rainbowify-line {
	local -i i=0
	integer ndx=$2
	while ((i<$#1)); do
		printf "\e[38;5;${colors[ndx+1]}m%s" ${1:$i:$cbc}
		i=$((i+cbc))
		ndx=$(( ((ndx+1)%30) ))
	done
	printf '\e[0m\n'
}

function rainbowify-stdin {
	IFS=$'\0'
	while read -r ln; do
		# remove any existing ansi escapes
		while [[ $ln =~ $reANSI ]] { ln=${ln:0:$((MBEGIN-1))}${ln:$MEND}; }
		hue=$(((hue+1)%30))
		rainbowify-line "$ln" $hue
	done
}

function cat-one-file { # {{{1
	local INPUT=0
	[[ $1 != '-' ]]&& {
		[[ -e $1 ]]|| {
			-warn "No such file or directory %S${1:gs/%/%%}%s."
			return 1
		  }
		[[ -d $1 ]]&& {
			-warn "%S${1:gs/%/%%}%s is a directory."
			return 1
		  }
		[[ -r $1 ]]&& {
			-warn "Cannot read %S${1:gs/%/%%}%s."
			return 1
		  }
		exec {INPUT}<$1
	  }
	rainbowify-stdin <&$INPUT
	((INPUT))&& exec {INPUT}>&-
	return 0
} # }}}1

function randomize-hue {
	hue=$( printf '%d' "'$(dd status=none count=1 bs=1 if=/dev/random)" )
	hue=$((hue%30))
}

((hue))|| randomize-hue
(($#))|| set -- - # Normalize input from STDIN handling
for f { cat-one-file $f; }


# Copyright © 2017 by Tom Davis <tom@greyshirt.net>.
