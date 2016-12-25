# @(#)[perl6.zshrc 2016/10/15 03:12:12 tw@csongor.lan]
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
	[[ -f $log.3.gz ]]&& rm $log.3.gz
	[[ -f $log.2.gz ]]&& mv $log.2.gz $log.3.gz
	[[ -f $log.1.gz ]]&& mv $log.1.gz $log.2.gz
	[[ -f $log ]]&& gzip -o $log.1.gz $log
	date -u +'===| %Y-%m-%d %H:%M:%S Z |===' >$log
	$rbrew $@ 2>&1 | tee -a $log
  }

path+=$RAKUDO_BIN
typeset -x -m 'RAKUDO_*' POD_TO_TEXT_ANSI

