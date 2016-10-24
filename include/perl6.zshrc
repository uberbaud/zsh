# $Id: perl6.zshrc,v 1.4 2016/10/15 03:12:12 tw Exp $
# vim: tabstop=4 filetype=zsh

RAKUDO_HOME="$XDG_DATA_HOME/rakudobrew"
RAKUDO_BIN="$RAKUDO_HOME/bin"
POD_TO_TEXT_ANSI=1

function rakudobrew {
	typeset -- rbrew="$RAKUDO_BIN/rakudobrew"
	[[ -f $rbrew ]] || die "No file %B$rbrew%b."
	[[ -x $rbrew ]] || die "%B$rbrew%b is not executable."
	(($#))|| set build moar
	[[ $1 == build ]]|| {
		$rbrew $@
		return $?
	  }

	h1 'Updating `rakudobrew`' >&2
	$rbrew self-upgrade

	h1 "rakudobrew $*"
	typeset -- log=$HOME/log/rakudobrew
	[[ -f $log ]]&& gzip $log
	date -u +'===| %Y-%m-%d %H:%M:%S Z |===' >$log
	$rbrew $@ 2>&1 | tee -a $log
  }

path+=$RAKUDO_BIN
typeset -x -m 'RAKUDO_*' POD_TO_TEXT_ANSI

