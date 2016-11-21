# @(#)[:5qhPljJRVwa`1@n|4$2n: 2016/11/21 00:59:30 tw@csongor.lan]
# vim: ft=zsh tabstop=4 textwidth=72 noexpandtab nowrap

typeset -a	AUTOPAGE_COMMANDS=( whois )
typeset -A	AUTOPAGE_CUSTOMS
AUTOPAGE_CUSTOMS=()

typeset --	AskFirst="$ZDOTDIR/bin/ask-first.zsh"
typeset --	clpath='~/.config/clisp'
typeset -Ag	WRAP_COMMANDS=(
	# ───────────────────────────────────────────────────────────────────
	#  autopage
	'b' "autopage $USRBIN/perl/bible.pl"
	'dmidecode' "autopage $AsRoot $SYSLOCAL/sbin/dmidecode"

	# ───────────────────────────────────────────────────────────────────
	#  sudo
	'halt' "$AsRoot /sbin/halt -p"
	'reboot' "$AsRoot /sbin/reboot"
	'shutdown' "$AsRoot /sbin/shutdown"

	# ───────────────────────────────────────────────────────────────────
	#  general helper functions
	'scrub' 'cd ~;history -c;echo -en '\''\e[0;0H\e[2J\e[3J'\'

	# ──────────────────────────────────────────────────────────────────
	# ───────────────────────────────────────────────────────────────────
	#  date helper
	'diso' "/bin/date +'$ISO_DATE'"
	'wiso' "/bin/date +'$ISO_WEEK'"
	'today' "$Z/bin/now.zsh -d"
	'utc' "/bin/date -u +'$ISO_DATE'"

	# ───────────────────────────────────────────────────────────────────
	#  wrap to a shorter command name
	'pass' "$USRBIN/pass-gen"
	#'off' ". $USRBIN/off.sh"
	#'modver' "$USRBIN/modver.pl"	# get version of perl modules

	# ───────────────────────────────────────────────────────────────────
	#  add default options or use specific path
	'bc' '/usr/bin/bc $@ $BC_ENV_ARG'
	'clear' "printf '\\e[0;0H\\e[2J\\e[3J'; eval"
	# 'clisp' "$SYSLOCAL/bin/clisp -i $clpath/init.lisp -lp $clpath/lib"

	'cdcl' 'cd;clear'

	'nifty' '/usr/local/bin/w3m http://nifty.nisusnet.com/nifty/gay; scrub'
	#
	'rsync' "$AskFirst rsync"
	# 'sbcl'  "$SYSLOCAL/bin/sbcl --userinit $XDG_CONFIG_HOME/sbcl/sbcl.rc"
	'scp' "$AskFirst scp"
	'sftp' "$AskFirst sftp"
	'sqlite3' '/usr/local/bin/sqlite3'
	'ssh' "$AskFirst ssh \$@; csongor-colors"
	#'tom' "$USRBIN/tweet.pl"

)


function autopage { # pipes cmd to pager if output would scroll the screen. {{{1

    typeset -- htxt='-';
    [[ -n $PAGER ]] || declare -- PAGER='less'

    (( $# >= 1 )) || die 'Missing required argument _command_.'

    typeset -i rc=0
    if [[ -t 1 ]]; then
        htxt="$( $@ )"
        rc=$?
        declare -i l="$(wc -l <<< $htxt)"
        (( $l < $(tput lines) )) && PAGER=cat
        $PAGER <<< $htxt
    else
        $@
        rc=$?
    fi

    return $rc
}; # }}}1

function BUILD_AUTOPAGE { WRAP_COMMANDS[$1]="autopage $2 $3"; }

#for b in $AUTOPAGE_BUILTINS; do BUILD_AUTOPAGE $b builtin $b; done
for c in $AUTOPAGE_COMMANDS; do BUILD_AUTOPAGE $c command $c; done
for k in ${(k)AUTOPAGE_CUSTOMS}; do
	BUILD_AUTOPAGE $k 'autopage' ${AUTOPAGE_CUSTOMS[$k]}
done

function WRAP:FUNCTION { f="$1"; shift; WRAP_COMMANDS[$f]="$*"; }

unset -f BUILD_AUTOPAGE


# Copyright (C) 2015 by Tom Davis <tom@greyshirt.net>.
