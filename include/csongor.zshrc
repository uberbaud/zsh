# @(#)[:;D;F2<M+vG`6ZAW*r1=i: 2017/07/04 22:03:02 tw@csongor.lan]
# vim: tabstop=4 filetype=zsh

BROWSER='/home/tw/bin/start-surf2'
export BROWSER

# ────────────────────────────────── BEGIN: TERM Colors ───── {{{1

CSONGOR_XTERM_WINDOW_BG='#FFFFFF'
CSONGOR_XTERM_WINDOW_FG='#000000'

typeset -xm 'CSONGOR_XTERM_*'
function set-colors-bg-fg {
	printf '\e]11;%s\a\e]10;%s\a' $1 $2
}
function csongor-colors {
	set-colors-bg-fg $CSONGOR_XTERM_WINDOW_BG $CSONGOR_XTERM_WINDOW_FG
}
csongor-colors
# ──────────────────────────────────── END: TERM Colors ───── }}}1

function set_prompt { # set prompt {{{1
	typeset -a prmpt=(
		'%F{3}'	'['						# amber [
			'%F{2}'	'%n'				# green $USER
			'%F{3}'	'@'					# amber @
			'%F{2}'	'%m'				# green machine name
					' '					# space
			'%F{4}'	'%12<…<'			# blue truncate to last 12 chars
					'%~'				#   path name with ~ for /home/$USER
					'%<<'				#   truncate to here, no further
		'%F{3}'	']'						# amber ]
		'%('							# conditional
			'?'							#   test $? -eq 0
			'.'	''						#   nothing if true
			'.'	'%K{224}%F{1}[%?]%f%k'	#   red_on_light_red "[$?]" if false
		 ')'							# end conditional
		'%('							# conditional
			1V							# test psvar[1] // ERRNO_PROMPT_STRING
			'.'	"%K{224}%F{1}[%1v]%f%k"	#   -n psvar[1]
			'.'							#   -z psvar[1]
		  ')'							# end conditional
		'%f'	'%#'					# ansi_normal prompt (% or # if su)
		' '								#    space
	  )

	PROMPT=${(j::)prmpt} # join, with no separator
}
# ─────────────────────── END: prompt  ────── }}}1


# Copyright (C) 2015 by Tom Davis <tom@tbdavis.com>.
