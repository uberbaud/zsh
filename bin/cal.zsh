#!/usr/bin/env zsh
# @(#)[:e0$Emzv9aDN4!Og3WY9T: 2017/03/02 02:48:27 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

emulate -L zsh
. $USR_ZSHLIB/common.zsh|| exit 86
zmodload zsh/datetime

:needs /usr/bin/cal


typeset -- today; strftime -s today %d $EPOCHSECONDS
typeset -- search="${today/#0/ }\\>"
typeset -- replace=$'\e[48;5;147m\\1\e[0m'
typeset -- stdopts=(
	-m		# week starts on Monday (not Sunday)
)
(($#))&& { # with options, don't do the calendar bit {{{1
	:needs /usr/bin/sed
	/usr/bin/cal $stdopts $@ | /usr/bin/sed -E "s/($search)/$replace/g"
	exit 0
} # }}}1

:needs /usr/bin/calendar /usr/bin/sed

typeset -- nt=$'\n\t'	# multiline calendar events
typeset -- TODAY='' TOMORROW='' daystamp='' expectday='' ev='' H='' E=''
typeset -a tuple=() events=()
typeset -- calblob=$(
		/usr/bin/cal $stdopts | /usr/bin/sed -E "s/($search)/$replace/g"
	)
typeset -- evblob=$(/usr/bin/calendar)
integer TS=$EPOCHSECONDS		# use a single timestamp for everything,
								# avoids a potential problem where TODAY 
								# and TOMORROW are not contiguous
integer evsize=$((COLUMNS-23))	# cal output (20) + both borders + gutter

strftime -s TODAY '%b %d ' $TS
strftime -s TOMORROW '%b %d ' $((TS+86400))

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
	ev=$tuple[2]
	if [[ $ev =~ 'BIRTHDAY' ]]; then
		H=$'\e[48;5;225m'; E=$'\e[0m'
		ev=${ev:0:$((MBEGIN-1))}$'\e[48;5;128;38;5;226m🎂 '
	else
		H=''; E=''
	fi
	while (($#ev>evsize)); do
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

typeset -a cal=( ${(f)calblob} )

# print calendar and events where it's one for one
# the ANSI sequence \e[#G moves to the absolute column #
while (($#cal&&$#events)); do
	printf ' %s \e[23G %s\n' $cal[1] $events[1]
	shift cal events
done

for c ($cal) printf ' %s\n' $c				# print any remaining calendar
for e ($events) printf '\e[23G %s\n' $e		# print any remaining events

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
