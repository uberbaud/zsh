# @(#)[:Jnl5Rtp0Fd_I(4heCgMB: 2017/04/12 03:20:09 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

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
	local pTail=pg-dump
	local fOut='pgdb-dump.psql'
	local admin='_postgresql'		# superuser on OpenBSD
	[[ -n ${XDG_DATA_HOME:-} ]]|| die '%BXDG_DATA_HOME%b is not set.'
	[[ -d $XDG_DATA_HOME ]]|| die "No directory %F{5}\$XDG_DATA_HOME%f: %B${XDG_DATA_HOME:gs/%/%%}%b."
	[[ -d ${XDG_DATA_HOME}/$pTail ]]|| {
		mkdir $XDG_DATA_HOME/$pTail || die "Could not create directory %B\$XDG_DATA_HOME/${pTail:gs/%/%%}%b."
	}

	printf '  \e[34m>>>\e[39;1m pgdump\e[22m dumps everything to \e[1m%s\e[22m\n' '$XDG_DATA_HOME'/${pTail}/${fOut}
	yes-or-no "Continue" || return

	local F=${XDG_DATA_HOME}/${pTail}/${fOut}
	# rotate dumps, but only the ones that need it
	[[ -f $F ]]&& {
		[[ -f $F.1.gz ]]&& {
			[[ -f $F.2.gz ]]&& {
				[[ -f $F.3.gz ]]&& {
					[[ -f $F.4.gz ]]&& { rm $F.4.gz; }
					mv $F.{3,4}.gz
				}
				mv $F.{2,3}.gz
			}
			mv $F.{1,2}.gz
		}
		gzip -9 -o $F.1.gz $F
	}

	local opts=(
		--clean				# add DROP statements
		--if-exists			# add IF EXISTS statements to the DROPs
		--file=$F			# output file
		--verbose			# progress PLUS timing info in dump
		--username=$admin
	  )
	pg_dumpall $opts
} #}}}1

# Copyright © 2017 by Tom Davis <tom@greyshirt.net>.
