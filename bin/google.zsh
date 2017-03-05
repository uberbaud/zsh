#!/usr/bin/env zsh
# @(#)[:9go){JgHoqY)x$bWEG,e: 2017/03/05 06:21:02 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86

typeset -- wifi=iwm0

function istat { # {{{1
	/sbin/ifconfig $wifi \
		| /usr/bin/awk -F': ' '/^[[:blank:]]+status: / {print $2;}';
  } # }}}1

typeset -A conf=(
	nwid 'Google Starbucks'
)

:rootness:init

# down and clear
:rootness:cmd /sbin/ifconfig $wifi down
typeset -a props=( bssid chan inet inet6 mode nwid nwkey wpa wpakey )
typeset -a curnt=( ${(z)"$(
	/sbin/ifconfig $wifi	\
	| awk -F': ' '/^\tieee80211:/ {print $2;}'
  )"} )
for prop in $props; do
	:rootness:cmd /sbin/ifconfig $wifi "-$prop"
done

# set it up
-notify "Setting ${wifi:gs/%/%%} for %B${conf[nwid]}%b."
:rootness:cmd /sbin/ifconfig $wifi nwid ${conf[nwid]}
:rootness:cmd /sbin/ifconfig $wifi up

# wait for it
typeset -- istatus=$(istat)
while [[ $istatus == 'no network' ]]; do
	print -n .;
	sleep .8;
	istatus=$(istat)
done
print .

if [[ $istatus == 'active' ]]; then
	-notify 'Connected.'
	:rootness:cmd /sbin/dhclient $wifi
else
	-warn "connection status is: %B${istatus:gs/%/%%}%b."
fi

:rootness:finit


# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
