# @(#)[:LvGzAyJk$DKA,kZtJ;1[yt.zshrc 2016/10/31 06:18:43 tw@sam.lan]: 2017/01/04 22:54:04 tw@csongor.lan]
# vim: tabstop=4 filetype=zsh

# ────────────────────────────────── BEGIN: TERM Colors ───── {{{1

YT_XTERM_WINDOW_BG='#CCDDAA'
YT_XTERM_WINDOW_FG='#000000'

typeset -xm 'YT_XTERM_*'
function set-colors-bg-fg {
	printf '\e]11;%s\a\e]10;%s\a' $1 $2
}
function yt-colors {
	set-colors-bg-fg $YT_XTERM_WINDOW_BG $YT_XTERM_WINDOW_FG
}
yt-colors
# ──────────────────────────────────── END: TERM Colors ───── }}}1

function set_prompt { # set prompt {{{1
	typeset -a prmpt=(
		'%F{107}'	'['					# dark green [
			'%F{1}'	'%n'				# dark red $USER
			'%F{107}' '@'				# dark green @
			'%F{1}'	'%m'				# dark red machine name
					' '					# space
			'%F{19}' '%12<…<'			# blue truncate to last 12 chars
					'%~'				#   path name with ~ for /home/$USER
					'%<<'				#   truncate to here, no further
		'%F{107}' ']'					# dark green ]
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
