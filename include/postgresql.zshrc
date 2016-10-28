# @(#)[postgresql.zshrc 2016/10/23 02:58:04 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

PSQL_HOME=$XDG_CONFIG_HOME/pg
PSQLRC=$PSQL_HOME/psqlrc
PSQL_HISTORY=$PSQL_HOME/history

function psql { # {{{1
	export PGDATABASE="${PGDATABASE:-tw}"
	export PGUSER="${PGUSER:-tw}"
	warn $(typeset -m 'PG*')
	/usr/bin/env LESS='-iMSx4 -FXc' $SYSLOCAL/bin/psql "$@"
}

