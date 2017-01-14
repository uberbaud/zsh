#!/usr/bin/env zsh
# @(#)[ansi-rgb.zsh 2016/10/25 07:07:16 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t %F{1}R%f %F{2}G%f %F{4}B%f"
	'  Outputs the 256 color number of the %Brgb%b value.'
	'  Each of the %Brgb%b is a number between %B0%b and %B5%b.'
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

typeset -- rgb='%F{1}R%F{2}G%F{4}B%f'
typeset -a errmsg=(
 'I need %Bthree%b (3) numbers (%F{1}Red%f %F{2}Green%f %F{4}Blue%f),'
 'each between %B0%b and %B5%b.'
)

(($#==3))|| -die $errmsg

[[ $1 == <-> ]] || -die $errmsg
[[ $2 == <-> ]] || -die $errmsg
[[ $3 == <-> ]] || -die $errmsg

typeset -i R=$1
typeset -i G=$2
typeset -i B=$3

errmsg=( "$rgb values MUST be %B0%b, %B1%b, %B2%b, %B3%b, %B4%b, or %B5%b." )
# greater than or equal to 0
(($R>=0))|| -die  $errmsg
(($G>=0))|| -die  $errmsg
(($B>=0))|| -die  $errmsg
# less than or equal to 5
(($R<=5))|| -die  $errmsg
(($G<=5))|| -die  $errmsg
(($B<=5))|| -die  $errmsg

typeset -a hc=( '00' '32' '65' '99' 'CC' 'FF' )
typeset -i ansi_code=$(( 16 + (36 * R) + (6 * G) + B ))
typeset -- hexcode="${hc[R+1]}${hc[G+1]}${hc[B+1]}"
typeset -a _showme=(
	'\e[0m    \e[48;5;%dm            '
	'\e[0m    \e[38;5;%dm%s'
	'\e[0m     : %s\n'
  )
typeset -- showme='  '${(j..)_showme}
typeset -a fig=( ${(f)"$( figlet $ansi_code )"} )
printf '%40s %s\n' ' '                              $fig[1]
printf $showme $ansi_code $ansi_code 'ABCDefghÉçþð' $fig[2]
printf $showme $ansi_code $ansi_code '_0123456789-' $fig[3]
printf $showme $ansi_code $ansi_code '!@#$%^&*([{|' $fig[4]
printf '%17s %22s %s\n' "$ansi_code #$hexcode" ':'  $fig[5]

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
