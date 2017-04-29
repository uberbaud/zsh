#!/usr/bin/env zsh
# @(#)[:Gh_yxV#+HhAg%Wk{Rasr: 2017/04/29 07:20:27 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

. $USR_ZSHLIB/common.zsh || exit 86

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [%Uacct list%u]"
	'  Download (fetchmail), import into NMH (inc), and do some'
	'  processing.'
	"%T${this_pgm:gs/%/%%}%t -l%f"
	'  Lists available accounts.'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
function list-accts { # {{{2
	local laccts=$XDG_CONFIG_HOME/fetchmail/listAccts.zsh
	:needs $laccts
	$laccts
  } # }}}2
while getopts ':hl' Option; do
	case $Option in
		h)	-usage $Usage;										;;
		l)	list-accts; exit;									;;
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

typeset -- accToFetch=${XDG_CONFIG_HOME}/fetchmail/accTofetch.zsh
:needs $accToFetch fetchmail inc pick scan

typeset -- re_mb_typ1='^(\d+) (messages?) \((\d+) seen\) for (.*) at (.*)\.$'
typeset -- re_mb_typ2='^(\d+) (messages?) for (.*) at (.*)\.$'
typeset -- re_msg='^reading message (.*):(\d+) of (\d+) \('
typeset -- re_mb_empty='^fetchmail: No mail for (.*) at (.*)$'

typeset -- N W
typeset -- P='      %F{4}─%f'

( # subshell to localize setopt & cd
	setopt extended_glob	# allows #q glob modifier
	# #q forces the pattern in a string context to be globbed as a file
	[[ -n $(mhpath +inbox)/,*(#qN) ]]|| return
	cd $(mhpath +inbox)|| return
	-warn 'Cleaning out %Sinbox%s.'
	rm ,*
)

-notify 'Generating %Sfetchmailrc%s.'
$accToFetch $@

-notify 'Downloading remote messages…'
fetchmail 2>&1 | while read -r resp; do
	if   [[ $resp =~ $re_msg ]]; then
		continue
	elif [[ $resp =~ $re_mb_typ1 ]]; then
		W=${match[4]:gs/%/%%}
		M=${match[2]:gs/%/%%}
		N=$((match[1]-match[3]))
		if ((N)); then
			print -Pu 2 "$P Getting %F{5}$N%f $M for %F{5}$W%f."
		else
			print -Pu 2 "$P No new messages for %F{5}$W%f."
		fi
	elif [[ $resp =~ $re_mb_typ2 ]]; then
		W=${match[3]:gs/%/%%}@${match[4]:gs/%/%%}
		M=${match[2]:gs/%/%%}
		N=$((match[1]))
		if ((N)); then
			print -Pu 2 "$P Getting %F{5}$N%f $M for %F{5}$W%f."
		else
			print -Pu 2 "$P No new messages for %F{5}$W%f."
		fi
	elif [[ $resp =~ $re_mb_empty ]]; then
		print -Pu 2 "$P No new messages for %F{5}${match[2]:gs/%/%%}%f."
	else
		-warn $resp
	fi
done
# regenerate fetchmailrc with all accounts enabled
$accToFetch

typeset -i msgCount=$(egrep -c '^From ' /var/mail/tw)

(($msgCount))|| { -notify "Nothing more to do, quitting."; return 0; }

mark +inbox all -sequence oldhat
-notify 'Incorporating new mail'
inc -nochangecur >/dev/null

typeset -A groups=()
function group {
	mark +inbox -sequence x -delete all
	x=${${"$(pick +inbox -sequence x -sequence $@)":-0}% *}
	mark +inbox -sequence x -delete oldhat
	y=${${"$(pick +inbox x -nolist)":-0}% *}
	groups+=( $1 "new $y, total $x" )
	mark +inbox -sequence lists -add $1
} 2>/dev/null

group obsd		--list-id 'source-changes\.openbsd\.org'
group zshwork	--list-id 'zsh-workers\.zsh\.org'
group drgfly	--list-id 'users\.dragonflybsd\.org'
scan +inbox notlists
printf '  %-8s: %s\n' ${(kv)groups}

# Copyright © 2017 by Tom Davis <tom@greyshirt.net>.
