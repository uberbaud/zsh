#!/usr/bin/env zsh
# @(#)[:e0$Emzv9aDN4!Og3WY9T: 2017/08/11 14:06:35 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

emulate -L zsh
. $USR_ZSHLIB/common.zsh|| exit 86
zmodload zsh/datetime	|| exit 86

typeset -A calendarOpts=()
calendarOpts[-A]=1	# override default friday behavior
typeset -a calOpts=(
	-m		# week starts on Monday (not Sunday)
)
integer TS=$EPOCHSECONDS	# use a single timestamp for everything,
							# avoiding a potential problem where TODAY 
							# and TOMORROW are not contiguous,
							# or TODAY ¬= today
typeset -i DOM;  strftime -s DOM  %d $TS
typeset -l MON;  strftime -s MON  %b $TS
typeset -i YEAR; strftime -s YEAR %Y $TS
typeset -- yearOnly=false withWeek=false

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [%T-w%t|%T-y%t] [%T-A%t %Unum%u] [%T-B%t %Unum%u] [[%Uday%u] %Umonth%u] [%Uyear%u]"
	'  Wraps %Tcal%t and %Tcalendar%t and tweaks their output. Woot!'
	'  %T-w%t      Display week numbers too.'
	'  %T-y%t      Display whole year (no %Tcalendar%t output).'
	'  %T-A%t %Unum%u  Show events for %Udays%u after.'
	'  %T-B%t %Unum%u  Show events for %Udays%u before.'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
while getopts ':wyA:B:h' Option; do
	case $Option in
		w)	calOpts+=( -w ); withWeek=true;						;;
		y)	yearOnly=true; calOpts+=( -y );						;;
		A)	calendarOpts[-A]=$OPTARG;							;;
		B)	calendarOpts[-B]=$OPTARG;							;;
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

(($#>3))&& -die 'Too many arguments:' "$@"
if (($#==1)) && [[ $1 == [0-9][0-9][0-9][0-9] ]]; then
	calOpts+=( $1 )
	yearOnly=true
	shift
elif (($#)); then
	typeset -l o
	for o in "$@"; do
		case $o in
			[0-9][0-9][0-9][0-9])
				YEAR=$o
				;;
			[0-9][0-9]|[0-9])
				DOM=$o
				;;
			jan*|feb*|mar*|apr*|may*|jun*|jul*|aug*|sep*|oct*|nov*|dec*)
				MON=${o:0:3}
				;;
			*)
				-die "Unparseable parameter %B${o:gs/%/%%}%b."
				;;
		esac
	done
	calOpts+=( $MON $YEAR )
fi

# ───────────────────────────────────────────────────── GET CALENDAR ───
:needs /usr/bin/cal /usr/bin/sed

local search="\\<($DOM)\\>"; ((DOM<10))&& search=" $search"
local replace=$'\e[48;5;147m&\e[0m'
typeset -a cal=( ${(f)"$(
		/usr/bin/cal $calOpts 2>&1			|
		/usr/bin/sed -E "s/$search/$replace/g"
	)"} )
# remove last line if blank
[[ $cal[-1] =~ '^ *$' ]]&& shift -p cal

# with options, don't do the events bit
$yearOnly && { printf ' %s\n' $cal; exit 0; }

# ───────────────────────────────────────────────────── GET  EVENTS ───
:needs /usr/bin/calendar

typeset -a months=( jan feb mar apr may jun jul aug sep oct nov dec )
typeset -i MM=$months[(i)$MON]
calendarOpts[-t]=$YEAR''${(l:2::0:)MM}''${(l:2::0:)DOM}

typeset -- nt=$'\n\t'	# multiline calendar events
typeset -- TODAY='' TOMORROW='' daystamp='' expectday='' ev='' H='' E=''
typeset -a tuple=() events=()
typeset -- evblob=$(/usr/bin/calendar ${(kv)calendarOpts})
typeset -i calSize=23	# cal output (20) + both borders + gutter
if $withWeek; then ((calSize+=5)); fi
integer evsize=$((COLUMNS-calSize))

strftime -s TODAY '%b %d ' $TS
strftime -s TOMORROW '%b %d ' $((TS+86400))

# ──────────────────────────────────────────── FORMAT events listing ───
evblob=${evblob//$nt/ } # deformat multiline
for ln in ${(f)evblob}; do
	tuple=( ${(ps:\t:)ln} )
	[[ $tuple[1] == $expectday ]]|| {
		expectday=$tuple[1]
		case $expectday in
			$TODAY)		events+=( $'\e[1m   today\e[22m' );			;;
			$TOMORROW)	events+=( $'\e[1m   tomorrow\e[22m' );		;;
			*)			events+=( $'\e[1m   '$expectday$'\e[22m' );	;;
		esac
	  }
	ev="${tuple[2,-1]}"
	while [[ $ev =~ '  +' ]] { ev=${ev:0:$MBEGIN}${ev:$MEND}; }
	if [[ $ev =~ 'BIRTHDAY' ]]; then
		H=$'\e[48;5;225m'; E=$'\e[0m'
		ev=${ev:0:$((MBEGIN-1))}$'\e[48;5;128;38;5;226m🎂 '
	else
		H=''; E=''
	fi
	while ((evsize<$#ev)); do
		T=${${ev:0:$evsize}% *}
		while [[ $T == *' ' ]] { T=${T:0:-1} } # remove trailing spaces
		events+=( $H$T$E )
		ev=${ev:$#T}
		while [[ $ev == ' '* ]] { ev=${ev:1} } # remove leading spaces
		ev='    '$ev
	done
	events+=( $H$ev$E )
done

# ─────────────────────────────── VERTICALLY CENTER cal and events ───
integer l=$(($#cal-$#events))
if ((l<0)); then
	repeat $((-l/2)) cal=( ' ' $cal )
elif ((0<l)); then
	repeat $((l/2)) events=( ' ' $events )
fi

# ──────────────────────────────────────────────────────────── PRINT ───
# print calendar and events where it's one for one
# the ANSI sequence \e[#G moves to the absolute column #
while (($#cal&&$#events)); do
	printf " %s \e[${calSize}G %s\n" $cal[1] $events[1]
	shift cal events
done

# at most, one of these will happen
for c ($cal) printf ' %s\n' $c				# print any remaining calendar
for e ($events) printf "\e[${calSize}G %s\n" $e		# print any remaining events

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
