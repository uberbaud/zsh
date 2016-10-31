# @(#)[sam.zshrc 2016/10/31 05:36:20 tw@sam.lan]
# vim: tabstop=4 filetype=zsh nowrap

# THIS FILE CONTAINS
#   anything and everything that is specific to THIS installation 
#   (user@machine). And it is included by .zshrc as ${HOST%%.*}.zshrc
# BUT NOT OS specific things which are included as $(uname).zshrc

USR_SHLIB=$XDG_DATA_HOME/lib/bash
export USR_SHLIB

# ────────────────────────────────── BEGIN: TERM Colors ───── {{{1

SAM_XTERM_WINDOW_BG='#424242'
SAM_XTERM_WINDOW_FG='#42FE42'

typeset -xm 'SAM_XTERM_*'

function set-colors {
	printf "\e]11;%s\a\e]10;%s\a" $1 $2
  }
set-colors $SAM_XTERM_WINDOW_BG $SAM_XTERM_WINDOW_FG

# ──────────────────────────────────── END: TERM Colors ───── }}}1
# ────────────────────────────────── BEGIN: PS1 Colors ────── {{{1

function set_prompt { # called from zsh-ux.zshrc
	typeset -a prmpt=(
		'%F{1}'	'['						# red [
			'%F{3}'	'%n'				# amber $USER
			'%F{1}'	'@'					# red @
			'%F{3}'	'%m'				# amber machine name
					' '					# space
			'%F{2}'	'%12<…<'			# green truncate to last 12 chars
					'%~'				#   path name with ~ for /home/$USER
					'%<<'				#   truncate to here, no further
		'%F{1}'	']'						# red ]
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

# ──────────────────────────────────── END: PS1 Colors ────── }}}1

# Copyright (C) 2015 by Tom Davis <tom@tbdavis.com>.
