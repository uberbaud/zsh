#!/usr/bin/env zsh
# @(#)[:Dy_RdOcBKzd$bs1jX,=O: 2017/06/13 06:11:53 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

emulate -L zsh
. ${USR_ZSHLIB}/common.zsh || exit 86

:needs Xdialog

typeset -- NL=$'\n'
typeset -- allset=''
allset+=$( (: ${XDG_DATA_HOME:?}) 2>&1 )
allset+=$( (: ${USR_ZSHLIB:?}) 2>&1 )
allset+=$( (: ${ZDOTDIR:?}) 2>&1 )
[[ -z $allset ]]|| DIE ${allset:gs/zsh: /$NL}

function DIE {
	Xdialog --no-buttons --infobox $1 0 0 4500
	exit 1
  }
(($#))&& DIE 'Unexpected arguments.'

cd ${XDG_DATA_HOME}/disfree || DIE 'Could not `cd` to $XDG_DATA_HOME/disfree'

typeset -a F=()
integer i=0
for f (*(.)) { F+=( $((++i)) $f ); }
F+=( 0 '<new>' )
typeset -A G=( $F )
typeset -a opts=(
	--no-tags
	--menubox
		'Edit which file?'
		524x$((($#F/2)*29+100))
		$#F
	${(kv)F}
  )

Xdialog --stdout $opts 2>&1 | read fndx
on-error exit 0

if ((fndx)); then
	fname=$G[$fndx]
else
	Xdialog --stdout --inputbox 'New file name:' 524x148 | read fname
	on-error exit 0
fi

${ZDOTDIR}/bin/dfvim.zsh $fname


# Copyright © 2017 by Tom Davis <tom@greyshirt.net>.
