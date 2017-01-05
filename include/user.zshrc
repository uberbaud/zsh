# @(#)[:w$5whw8(m0HW}8aT?EPw: 2017/01/05 06:44:37 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

BC_ENV_ARG="$XDG_CONFIG_HOME/etc/bc.rc"
CALENDAR_DIR="$XDG_CONFIG_HOME/calendar"
EMAIL='tom@greyshirt.net'
LESS='-RcgiSw#8'
LESSHISTFILE='-'
linode='li131-170.members.linode.com'
LINODE_IP='69.164.216.170'
LINODE_IPv6='2600:3c03::f03c:91ff:fe96:e402'
LOGNAME='tw'
PAGER='/usr/bin/less'
TEMPLATES_FOLDER="$XDG_DATA_HOME/templates"
TIMEFMT='    %*E real    %U user    %S system    %P cpu    %MMB mem'
TMPDIR="$XDG_DATA_HOME/temp"
UBERBAUD_NET="$LINODE_IP"
radio_wazee='http://wazee.org/128.pls'

export BC_ENV_ARG		LESS		PAGER		CALENDAR_DIR	LOGNAME
export LESSHISTFILE		TMPDIR		EMAIL		TEMPLATES_FOLDER

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

for c ( find new newest p ) alias $c="noglob $c"
alias prn="printf '  |%s|\n'"
alias cls='noglob clear ls'
