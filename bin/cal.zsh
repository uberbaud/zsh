#!/usr/bin/env zsh
# @(#)[cal.zsh 2016/10/25 07:07:16 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

emulate -L zsh
. "$USR_ZSHLIB/common.zsh"


typeset -- today=$(date +%d)
typeset -- search="${today/#0/ }\\>"
typeset -- replace=$'\e[48;5;147m\\1\e[0m'
typeset -- stdopts=(
	-m		# week starts on Monday (not Sunday)
)

/usr/bin/cal $stdopts $@ | /usr/bin/sed -E "s/($search)/$replace/"

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
