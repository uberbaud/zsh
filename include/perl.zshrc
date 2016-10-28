# @(#)[perl.zshrc 2016/05/10 05:58:03 tw@csongor.lan]
# vim: tabstop=4 filetype=zsh

# ---------- local::lib Stuff ----------
# local::lib is not really needed with perlbrew, and can cause problems with 
# XS modules (though everything seems to work with pure perl modules).  
# local::lib is also potentially helpful with application specific perl 
# libraries.

# ------------ cpanm Stuff -------------
PERL_CPANM_HOME="$XDG_DATA_HOME/cpanm"
typeset -x -m 'PERL_CPANM_*'

# ---8<--- perlbrew Stuff ----8<----
PERLBREW_ROOT="$XDG_DATA_HOME/perl5/perlbrew"
PERLBREW_HOME="$XDG_CACHE_HOME/perlbrew"
PERLBREW_SKIP_INIT=''
PERLBREW_LIB=''
typeset -x -m "PERLBREW_*"

[[ -f $PERLBREW_ROOT/etc/bashrc ]] && {
	FINIT: "source $PERLBREW_ROOT/etc/bashrc"
}

# perlbrew sets MANPATH, which on OpenBSD replaces the standard path, so unset 
# it.
#unset MANPATH
# then, use the `man` option -m to append the perlbrew set environment 
# variable to the path rather than replacing it.
#===================================
# perlbrew on OpenBSD apparently puts man pages in /usr/share/man
# function man { /usr/bin/man -m "$PERLBREW_MANPATH" "$@"; }

# --->8--- perlbrew Stuff ---->8----

# ----8<---- Perl Stuff ----8<----

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

typeset -x PERL5LIB FTP_PASSIVE

# ---->8---- Perl Stuff ---->8----
