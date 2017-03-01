#!/usr/bin/env zsh
# @(#)[:e0$Emzv9aDN4!Og3WY9T: 2017/03/01 07:08:35 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

emulate -L zsh
. $USR_ZSHLIB/common.zsh|| exit 86

:needs /usr/bin/cal

typeset -- today=$(date +%d)
typeset -- search="${today/#0/ }\\>"
typeset -- replace=$'\e[48;5;147m\\1\e[0m'
typeset -- stdopts=(
	-m		# week starts on Monday (not Sunday)
)

(($#))&& {
	:needs /usr/bin/sed
	/usr/bin/cal $stdopts $@ | /usr/bin/sed -E "s/($search)/$replace/g"
	exit 0
}

:needs /usr/bin/calendar

typeset -- nt=$'\n\t'	# multiline calendar events
typeset -- day=''
typeset -- ev='' e1='' pref=''
typeset -a tuple=()
typeset -a events=()
typeset -- calblob=$(
	/usr/bin/cal $stdopts | /usr/bin/sed -E "s/($search)/$replace/g"
	)
typeset -- evblob=$(/usr/bin/calendar)
integer evsize=$((COLUMNS-23))

evblob=${evblob//$nt/ }
for ln in ${(f)evblob}; do
	tuple=( ${(ps:\t:)ln} )
	[[ $tuple[1] == $day ]]|| {
		day=$tuple[1]
		events+=( $'\e[1m'$day$'\e[22m' )
	  }
	ev=$tuple[2]
	while (($#ev>evsize)); do
		T=${pref}${${ev:0:$evsize}% *}
		while [[ $T == *' ' ]] { T=${T:0:-1} } # remove trailing spaces
		events+=( $T )
		pref='    '
		ev=${ev:$#T}
		while [[ $ev == ' '* ]] { ev=${ev:1} } # remove leading spaces
	done
	events+=( ${pref}$ev )
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
