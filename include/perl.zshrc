# @(#)[:Y60M?doOzbx-Yy|`$9hZ: 2017/06/03 19:45:11 tw@csongor.lan]
# vim: tabstop=4 filetype=zsh


# ---------- local::lib Stuff ----------
# local::lib is not really needed with perlbrew, and can cause problems with 
# XS modules (though everything seems to work with pure perl modules).  
# local::lib is also potentially helpful with application specific perl 
# libraries.

# ------------ cpanm Stuff -------------
PERL_CPANM_HOME="$XDG_DATA_HOME/cpanm"
typeset -x -m 'PERL_CPANM_*'

# ---------- perlbrew Stuff ------------
PERLBREW_ROOT="$XDG_DATA_HOME/perl5/perlbrew"
PERLBREW_HOME="$XDG_CACHE_HOME/perlbrew"
PERLBREW_SKIP_INIT=''
PERLBREW_LIB=''
typeset -x -m "PERLBREW_*"

[[ -f $PERLBREW_ROOT/etc/bashrc ]] && {
	FINIT: "source $PERLBREW_ROOT/etc/bashrc"
}

# perlbrew sets MANPATH, which on OpenBSD replaces the standard path, so 
# unset it.
unset MANPATH
# then, use the `man` option -m to append the perlbrew set environment 
# variable to the path rather than replacing it.
#===================================
# perlbrew on OpenBSD apparently puts man pages in /usr/share/man
# function man { /usr/bin/man -m "$PERLBREW_MANPATH" "$@"; }

function perlbrew { #{{{1
	: ${PERLBREW_HOME:?} ${PERLBREW_BIN:?}
	OLDBREW=$PERLBREW_PERL
	typeset -a MODLIST= ( $( perlbrew list-modules | egrep -v '^Perl$' ) )
	local pbrew="$PERLBREW_BIN/rakudobrew"
	local pbdspl=${${${pbrew/#$XDG_DATA_HOME/\$XDG_DATA_HOME}/#$HOME/\~}:gs/%/%%}
	[[ -f $pbrew ]] || {
		h1 'Installing perlbrew'
		local xi=${HOME}/hold/upsys/bin/install-perlbrew.zsh
		needs $xi
		$xi
		[[ -f $pbrew ]]|| die "Did not install %B${pdbspl}%b."
	  }

	[[ -f $pbrew ]] || die "%B$pbdspl%b does not exist."
	[[ -x $pbrew ]] || die "%B$pbdspl%b is not executable."
	(($#))|| set install --switch stable
	[[ $1 == install ]]|| {
		$pbrew $@
		return $?
	  }

	h1 'Updating `perlbrew`' >&2
	$pbrew self-upgrade

	h1 "perlbrew $*"
	$pbrew $@

	local cpanm=${PERLBREW_HOME}/bin/cpanm
	[[ -f $cpanm ]]|| {
		h1 "perlbrew install-cpanm"
		$pbrew install-cpanm
	}

	[[ $OLDBREW == $PERLBREW_PERL ]]&& return 0

	h1 "importing previously installed modules"
	cpanm $MODLIST
  } # }}}1

# -------- General Perl Stuff ----------
PERL_UNICODE='AS'
PERL5LIB="$USRLIB/perl"
USR_PLIB="$PERL5LIB"

# DON'T USE cpan accidentally
function cpan {
	typeset -a cpans=( 'cpanm' $(whence -pa cpan) )
	cpans=( ${cpans:gs/%/%%} )
	warn 'Did you mean one of:' "%F{2}${^cpans[@]}%f"
  }

# cpan behind a firewall, and sometimes other benefits
FTP_PASSIVE="1 cpan -i Net::FTP"

typeset -x PERL5LIB FTP_PASSIVE PERL_UNICODE

