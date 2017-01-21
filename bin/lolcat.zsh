#!/usr/bin/env zsh
# @(#)[:DOJopgjq@V8T3(fNoa#V: 2017/01/21 06:36:35 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

. $USR_ZSHLIB/common.zsh || exit 86
zmodload zsh/mathfunc || exit 86

# The $colors array was generated using the formula
#   16 + (36*R) + (6*G) + B
# for values of R, G, and B
#
#     R  0 1 1 2 2 3 3 4 4 5 5 5 4 4 3 3 2 2 1 1 0 0 0 0 0 0 0 0 0 0
#     G  0 0 0 0 0 0 0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 5 4 4 3 3 2 2 1 1
#     B  5 5 4 4 3 3 2 2 1 1 0 0 0 0 0 0 0 0 0 0 0 1 1 2 2 3 3 4 4 5
#
typeset -a c1=(
	57    56    92    91   127   126   162   161   197   196
	202  166   172   136   142   106   112    76    82    46
	47    41    42    36    37    31    32    26    27    21
  )
# A more consistent intensity (brightness) by using only every other set 
# where R+G+B = 5, but at a loss of transition smoothness. This is 
# mostly noticible when using the invert flag.
typeset -a c2=(
	57    92    127   162   197
	202  172   142   112    82
	47    42    37    32    27
  )
typeset -a colors=( $c1 )

typeset -i -- hue=0 cbc=2 C=$#colors bfg=38 shft=2
typeset    -- dashopt=false

function reqFloat {
	[[ $3 =~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)([eE][0-9]+)?$' ]]|| {
		-die "Option %S-$1%s (%B$2%b) is not a valid %Bfloat%b."
	  }
	typeset -g $2=$3
}
function reqInt {
	[[ $3 =~ '^[+-]?[0-9]+$' ]]|| {
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
	'  -i  Invert. Color background rather than foreground.'
	'      This also forces the line length to %S$COLUMNS%s.'
	"  -c  Characters per color. The default is %B${cbc}%b."
	"  -s  Shift or slope. Changes the color shift per line."
	"      The default is %B${shft}%b."
	"  -t  Use color %Btable 2%b. The default is %Btable 1%b."
	"      Table 1 has 30 colors, smooth hue change, and rough brightness."
	"      Table 2 has 15 colors, rough hue change, and smooth brightness."
	"  -u  Hue (0 → $#c1) %B0%b, the default, means random."
	"      the range with %T-t%t is 0 → $#c2."
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
	'%F{172}These options are not compatible with the %Bruby%b%F{172} version.%f'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
while getopts ':c:is:tu:h' Option; do
	case $Option in
		c)	reqInt $Option cbc $OPTARG;							;;
		i)	bfg=48;typeset -L $COLUMNS ln='';					;;
		s)	reqInt $Option shft $OPTARG;						;;
		u)	reqInt $Option hue $OPTARG;							;;
		t)	colors=( $c2 ); C=$#colors;							;;
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
((hue<0))&&		-die "%Shue%s must be between %B0%b and %B$C%b (incl)."
((hue>C))&&		-die "%Shue%s must be between %B0%b and %B$C%b (incl)."

((shft<0))&& shft=$((shft%C)) # handle shft with large negative magnitude

typeset -r reANSI=$'\e''\[[0-9]+(;[0-9]+)*[mK]'

function rainbowify-line {
	local -i i=0
	integer ndx=$2
	while ((i<$#1)); do
		printf "\e[$bfg;5;${colors[ndx+1]}m%s" ${1:$i:$cbc}
		i=$((i+cbc))
		ndx=$(( ((ndx+1)%C) ))
	done
	printf '\e[0m\n'
}

function rainbowify-stdin {
	IFS=$'\0'
	while read -r ln; do
		# remove any existing ansi escapes
		while [[ $ln =~ $reANSI ]] { ln=${ln:0:$((MBEGIN-1))}${ln:$MEND}; }
		hue=$(((hue+shft+C)%C)) # handles negative shft values
		rainbowify-line "$ln" $hue
	done
}

function cat-one-file { # {{{1
	local INPUT=0
	if [[ $1 == '-' ]]; then
		$dashopt && {
			-warn 'Skipping redundant %Bstdin%b input.'
			return 1
		}
		dashopt=true
	else
		[[ -e $1 ]]|| {
			-warn "No such file or directory %S${1:gs/%/%%}%s."
			return 1
		  }
		[[ -d $1 ]]&& {
			-warn "%S${1:gs/%/%%}%s is a directory."
			return 1
		  }
		[[ -r $1 ]]|| {
			-warn "Cannot read %S${1:gs/%/%%}%s."
			return 1
		  }
		exec {INPUT}<$1
	fi
	rainbowify-stdin <&$INPUT
	((INPUT))&& exec {INPUT}>&-
	return 0
} # }}}1

function randomize-hue {
	hue=$( printf '%d' "'$(dd status=none count=1 bs=1 if=/dev/random)" )
	hue=$((hue%C))
}

((hue))|| randomize-hue
(($#))|| set -- - # Normalize input from STDIN handling
for f { cat-one-file $f; }


# Copyright © 2017 by Tom Davis <tom@greyshirt.net>.
