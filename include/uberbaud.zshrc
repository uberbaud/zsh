# @(#)[:dnct){FG$*~yAfmtq;d8: 2017/03/05 06:08:37 tw@csongor.lan]
# vim: tabstop=4 filetype=zsh nowrap

# THIS FILE CONTAINS
#   anything and everything that is specific to THIS installation 
#   (user@machine). And it is included by .zshrc as ${HOST%%.*}.zshrc
# BUT NOT OS specific things which are included as $(uname).zshrc

# ────────────────────────────────── BEGIN: TERM Colors ───── {{{1

UBERBAUD_XTERM_WINDOW_BG='#fdf6e3'
UBERBAUD_XTERM_WINDOW_FG='#268bd2'

typeset -xm 'UBERBAUD_XTERM_*'

function set-colors {
	printf "\e]11;%s\a\e]10;%s\a" $1 $2
  }
set-colors $UBERBAUD_XTERM_WINDOW_BG $UBERBAUD_XTERM_WINDOW_FG

# ──────────────────────────────────── END: TERM Colors ───── }}}1
# ────────────────────────────────── BEGIN: PS1 Colors ────── {{{1

function set_prompt { # called from zsh-ux.zshrc
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

# ──────────────────────────────────── END: PS1 Colors ────── }}}1


# Copyright (C) 2015 by Tom Davis <tom@tbdavis.com>.
