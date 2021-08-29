# @(#)[:w$5whw8(m0HW}8aT?EPw: 2017/07/30 01:03:46 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

export BC_ENV_ARG="$XDG_CONFIG_HOME/etc/bc.rc"
export CALENDAR_DIR="$XDG_CONFIG_HOME/calendar"
export EMAIL='tom@greyshirt.net'
export FCEDIT=nvim
export LESS='-RcgiSw#8'
export LESSHISTFILE='-'
export VULTR_IP='208.167.249.143'
export VULTR_IP6='2001:19f0:5:eef:5400:00ff:fe7e:34d3'
export LOGNAME=${LOGNAME:-tw}
export PAGER='/usr/bin/less'
export TEMPLATES_FOLDER="$XDG_DATA_HOME/templates"
export TMPDIR="$XDG_DATA_HOME/temp"

TIMEFMT='    %*E real    %U user    %S system    %P cpu    %MMB mem'
UBERBAUD_NET="$VULTR_IP"
radio_wazee='http://wazee.org/128.pls'

[[ $LESSHISTFILE =~ '^(-|/dev/null)$' ]]	\
	|| [[ -d ${LESSHISTFILE%*/} ]]			\
	|| mkdir -p ${LESSHISTFILE%*/}

function radio { # play radio wazee {{{1
	warn 'Playing possibly insecure playlist'
	declare -a opts=(
		#--really-quiet						# don't show anything
		-quiet								# don't show status line
		-allow-dangerous-playlist-parsing	# necessary for internet radio
	  )
	usr/local/bin/mplayer $opts $radio_wazee
}; # }}}1
function pkill { print -P '  Maybe use safe %Bpk%b? Or use %B=pkill%b.'; }
function lolcow { cowsay "$@" | lolcat; }

# noglob
for c ( find new newest p pkg ) alias $c="noglob $c"
# dealias next item too
for c ( clear doas ) alias $c="$c "

								compdef -d clear
alias math='noglob math';		function math { bc <<<"$*"; }
alias cowmath='noglob cowmath';	function cowmath { cowsay "$* = $(bc <<<"$*")" | lolcat; }
alias cls='clear ls'
alias cal='clear cal'
alias prn="printf '  \e[35m｢\e[39m%s\e[35m｣\e[39m\n'"
