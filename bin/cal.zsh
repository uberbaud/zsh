#!/usr/bin/env zsh
# @(#)[:e0$Emzv9aDN4!Og3WY9T: 2017/05/13 00:57:04 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86
zmodload zsh/datetime	|| exit 86

# ───────────────────────────────────────────────────── GET CALENDAR ───
:needs /usr/bin/cal /usr/bin/sed

integer TS=$EPOCHSECONDS	# use a single timestamp for everything,
							# avoiding a potential problem where TODAY 
							# and TOMORROW are not contiguous,
							# or TODAY ¬= today
integer today; strftime -s today %d $TS
local search="\\<($today)\\>"; ((today<10))&& search=" $search"
local replace=$'\e[48;5;147m&\e[0m'
typeset -- stdopts=(
	-m		# week starts on Monday (not Sunday)
)
typeset -a cal=( ${(f)"$(
		/usr/bin/cal $stdopts $@ 2>&1			|
		/usr/bin/sed -E "s/$search/$replace/g"
	)"} )
# remove last line if blank
[[ $cal[-1] =~ '^ *$' ]]&& shift -p cal

# with options, don't do the events bit
(($#))&& { printf ' %s\n' $cal; exit 0; }

# ───────────────────────────────────────────────────── GET  EVENTS ───
:needs /usr/bin/calendar

typeset -- nt=$'\n\t'	# multiline calendar events
typeset -- TODAY='' TOMORROW='' daystamp='' expectday='' ev='' H='' E=''
typeset -a tuple=() events=()
typeset -- evblob=$(/usr/bin/calendar)
integer evsize=$((COLUMNS-23))	# cal output (20) + both borders + gutter

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
			$TOMORROW)	events+=( $'\e[1m   tomorrow\e[22m' );			;;
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
	pref=''
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
	printf ' %s \e[23G %s\n' $cal[1] $events[1]
	shift cal events
done

# at most, one of these will happen
for c ($cal) printf ' %s\n' $c				# print any remaining calendar
for e ($events) printf '\e[23G %s\n' $e		# print any remaining events

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
