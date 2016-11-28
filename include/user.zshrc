# @(#)[:X*rE<fLZqlwVvd0[:X*rE<fLZqlwVvd0[:[user.zshrc 2016/11/04 05:30:45 tw@csongor.lan]EkW^X|n}S=KP,d+U%Vy: 2016/11/25 01:10:48 tw@csongor.lan]-nzw: 2016/11/28 07:07:16 tw@uberbaud.net]-nzw: 2016/11/28 07:07:27 tw@uberbaud.net]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

export BC_ENV_ARG="$XDG_CONFIG_HOME/etc/bc.rc"
export CALENDAR_DIR="$XDG_CONFIG_HOME/calendar"
export EMAIL='tom@greyshirt.net'
export LESS='-RcgiSw#8'
export LESSHISTFILE='-'
export LINODE_IP='69.164.216.170'
export LINODE_IPv6='2600:3c03::f03c:91ff:fe96:e402'
export LOGNAME='tw'
export PAGER='/usr/bin/less'
export TEMPLATES_FOLDER="$XDG_DATA_HOME/templates"
export TMPDIR="$XDG_DATA_HOME/temp"
export UBERBAUD_NET="$LINODE_IP"
export linode='li131-170.members.linode.com'
export radio_wazee='http://wazee.org/128.pls'

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

alias find='noglob find'
alias newest='noglob newest'
alias p='noglob p'

