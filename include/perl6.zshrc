# @(#)[:lziK)#|bsfHc9}(mzgFZ: 2017/04/26 00:38:44 tw@csongor.lan]
# vim: tabstop=4 filetype=zsh nowrap

RAKUDO_HOME="$XDG_DATA_HOME/rakudobrew"
RAKUDO_BIN="$RAKUDO_HOME/bin"
POD_TO_TEXT_ANSI=1

function rakudobrew {
	[[ -n ${RAKUDO_HOME:-} ]]|| die '%BRAKUDO_HOME%b is not set.'
	[[ -n ${RAKUDO_BIN:-} ]]|| die '%BRAKUDO_BIN%b is not set.'

	local rbrew="$RAKUDO_BIN/rakudobrew"
	local rbdspl=${${${rbrew/#$XDG_DATA_HOME/\$XDG_DATA_HOME}/#$HOME/\~}:gs/%/%%}
	[[ -f $rbrew ]] || {
		h1 'Installing rakudobrew'
		needs git
		git clone https://github.com/tadzik/rakudobrew $RAKUDO_HOME
		[[ -f $rbrew ]]|| die "Did not install %B${rdbspl}%b."
	  }

	[[ -f $rbrew ]] || die "%B$rbdspl%b does not exist."
	[[ -x $rbrew ]] || die "%B$rbdspl%b is not executable."
	(($#))|| set build moar
	[[ $1 == build ]]|| {
		$rbrew $@
		return $?
	  }

	h1 'Updating `rakudobrew`' >&2
	$rbrew self-upgrade

	h1 "rakudobrew $*"
	local log=$HOME/log/rakudobrew
	[[ -f $log.3.gz ]]&& rm $log.3.gz
	[[ -f $log.2.gz ]]&& mv $log.2.gz $log.3.gz
	[[ -f $log.1.gz ]]&& mv $log.1.gz $log.2.gz
	[[ -f $log ]]&& gzip -o $log.1.gz $log
	date -u +'===| %Y-%m-%d %H:%M:%S Z |===' >$log
	$rbrew $@ 2>&1 | tee -a $log
	[[ $(tail -n 1 $log) == 'Done, moar-nom built' ]] && {
		perl6 -e exit || return 1
		local p6ver=$(perl6 --version) VER=() timelog=$HOME/log/perl6-times
		while [[ $p6ver =~ '([^ ]+) version ([^ \n]+)' ]]; do
			VER+=( $match[1]\=$match[2] )
			p6ver=${p6ver:$MEND}
		done
		h1 'timing new build'; {
			printf '%s\n' ${(j:,:)VER}
			time (repeat 100 perl6 -e exit)
		} >>$timelog 2>&1
		tail -n 4 $timelog
	}
  }

path+=$RAKUDO_BIN
typeset -x -m 'RAKUDO_*' POD_TO_TEXT_ANSI

