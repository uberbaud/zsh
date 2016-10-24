# $Id: rlwrap.zshrc,v 1.3 2016/10/23 02:37:53 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab


RLWRAP_HOME="$XDG_DATA_HOME/rlwrap"
RLWRAP_EDITOR="$SYSLOCAL/bin/vim +%L"
RLWRAP_SQLITE3_OPTS=(
	--always-readline
	# --filter 'pipeto'				# allow output to `less`
	--case-insensitive				# for command completion
	--file "$RLWRAP_HOME/sql_words"	# use /sql_words/ for command completion
  )

function sqlite3 {
	export LESS='-iMSx4 -FXc'
	$SYSLOCAL/bin/rlwrap "${RLWRAP_SQLITE3_OPTS[@]}" sqlite3 "$@"
}

typeset -x -m 'RLWRAP_*'

# Copyright (C) 2015 by Tom Davis <tom@greyshirt.net>.
