# @(#)[:Jnl5Rtp0Fd_I(4heCgMB: 2017/04/11 19:16:30 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

PSQL_HOME=$XDG_CONFIG_HOME/pg
PSQLRC=$PSQL_HOME/psqlrc
PSQL_HISTORY=$PSQL_HOME/history

function psql { # {{{1
	export PGDATABASE="${PGDATABASE:-tw}"
	export PGUSER="${PGUSER:-tw}"
	warn $(typeset -m 'PG*')
	/usr/bin/env LESS='-iMSx4 -FXc' $SYSLOCAL/bin/psql "$@"
} #}}}1

function pgdump { #{{{1
	local opts=(
		--clean						# add DROP statements
		--if-exists					# add IF EXISTS statements to the DROPs
		-file='pgdb-dump.psql'		# output file
		--verbose					# progress PLUS timing info in dump
		--username='_postgresql'	# superuser on OpenBSD
	  )
	pg_dumpall $opts
} #}}}1

# Copyright © 2017 by Tom Davis <tom@greyshirt.net>.
