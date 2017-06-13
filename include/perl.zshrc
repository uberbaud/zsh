# @(#)[:Y60M?doOzbx-Yy|`$9hZ: 2017/06/04 04:46:15 tw@csongor.lan]
# vim: tabstop=4 filetype=zsh nowrap


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
	FINIT: "source ${PERLBREW_ROOT}/etc/bashrc"
	# the above sets MANPATH, but we don't need or want it
	FINIT: 'unset MANPATH'
	# the alias MUST come after the above bashrc as it uses the
	# perlbrew () form of the function declaration, which means the 
	# alias is expanded and the aliased value is used as the function 
	# name.
	FINIT: 'alias perlbrew=perlbrew-wrap'
}

function perlbrew-wrap { #{{{1
	: ${PERLBREW_HOME:?}
	OLDBREW=$PERLBREW_PERL
	local pbrew="$PERLBREW_HOME/bin/perlbrew"
	local pbdspl=${${${pbrew/#$XDG_DATA_HOME/\$XDG_DATA_HOME}/#$HOME/\~}:gs/%/%%}

	[[ -f $pbrew ]] || {
		h1 'Installing perlbrew'
		local xi=${HOME}/hold/upsys/bin/install-perlbrew.zsh
		needs $xi
		$xi
		[[ -f $pbrew ]]|| die "Did not install %B${pdbspl}%b."
		unset xi
	  }

	[[ -f $pbrew ]] || die "%B$pbdspl%b does not exist."
	[[ -x $pbrew ]] || die "%B$pbdspl%b is not executable."
	(($#))|| set -- install --switch stable
	[[ $1 == install ]]|| {
		perlbrew $@
		return $?
	  }

	h1 'Updating `perlbrew`' >&2
	perlbrew self-upgrade

	h1 'Getting current module list'
	typeset -a MODLIST= ( $( perlbrew list-modules | egrep -v '^Perl$' ) )

	h1 "perlbrew $*"
	perlbrew $@

	local cpanm=${PERLBREW_HOME}/bin/cpanm
	[[ -f $cpanm ]]|| {
		h1 "perlbrew install-cpanm"
		perlbrew install-cpanm
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

