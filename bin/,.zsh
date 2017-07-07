#!/usr/bin/env zsh
## @(#)[:Kz2XX!aYV8(8@VXU*wAz: 2017/07/07 04:33:19 tw@csongor.lan]
# vim: tabstop=4

. $USR_ZSHLIB/common.zsh|| exit 86
:needs apm xlock :log $XDG_DATA_HOME/bin/set_bg_per_battery.sh

:log timesheet xlock begin || -warn $REPLY

#================================================ Lock the Screen ======
# lock the screen immediately, but don't stop there
# -mode blank is good, and -mode moebius is cool, but -mode clock is 
# actually # useful.
#
#   opts: a negative number sets the maximum
typeset -a xlock_opts=(
	-planfont	'-*-dejavu sans-bold-r-normal-*-*-160-*-*-p-*-ascii-*'
	-mode		clock
	-count		20
	-size		-500
	-username	' '
	-password	' '
	-info		"'I can't die but once.' -- Harriet Tubman"
  )
/usr/X11R6/bin/xlock $xlock_opts &
typeset -i xlock_pid=$!

#========================================== Require sudo Password ======
# remove sudo timestamp for this user to ensure no root command can be 
# run without entering the password
[[ -x /usr/bin/sudo ]] && /usr/bin/sudo '-K'

#================================================== Hide SSH keys ======
# remove all keys from ssh-agent cache
[[ -x /usr/bin/ssh-add ]] && /usr/bin/ssh-add '-D'

#================================================= Stop the music ======
pkill -SIGINT -f '^zsh: aMuse player'

#======================================================== Suspend ======
# -Z hibernation -> disk
# -z suspend  (deep sleep)
# -S stand-by (light sleep)
# suspend (returns immediately, suspension is in future)

[[ ${1:-} =~ '^-[SzZ]$' ]]&& {
	sleep 0.5	# make sure xlock has had time to do its thing
	apm $1
  }


#===================== Pause here until we've unlocked the screen ======
wait $xlock_pid

#$was_playing && $USRBIN/amuse play
$XDG_DATA_HOME/bin/set_bg_per_battery.sh >> $HOME/log/battery-monitor

:log timesheet xlock end || -warn $REPLY

