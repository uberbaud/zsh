#!/usr/bin/env zsh
# @(#)[:J=U-vn#C+xt68#iB`gGG: 2016/12/02 03:52:21 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

emulate -L zsh

(($#))&& {
	printf '  pulls changes and recompiles zsh.rc & common.zsh, etc\n'
	exit 0
  }

typeset -- OPWD=$PWD

[[ -n ${ZDOTDIR:-} ]]|| -die '%S$Z%s is not defined.'
cd $ZDOTDIR|| -die 'Could not %Tcd%t to %S$ZDOTDIR%s.'

function  Log { print -Pu 2 " %F{4}>>>%f" $@; }

typeset -- branch=$( git rev-parse --abbrev-ref HEAD 2>/dev/null )
typeset -- unchanged='No local changes to save'
typeset -- stash=$unchanged
[[ $branch == master ]]|| {
	[[ -n $(git status --porcelain) ]]&& {
		Log " stashing changes on %B${branch:gs/%/%%}%b."
		stash=$( git stash save )
	  }
	Log 'Switching to %Bmaster%b branch.'
	git checkout master
  }
Log 'Syncing with %Bremote%b.'
git pull


if [[ $stash == $unchanged ]]; then
	Log 'Switching to %Blocal%b branch %F{5}'$HOST:r'%f.'
	git checkout $HOST:r

	Log 'Merging changes from %Bmaster%b.'
	git merge master
else
	print -Pu 2 ' %F{1}WARNING%f stashed changes. Do your own merge!'
fi

typeset -a exen=(
	". $ZDOTDIR/bin/rezsh.zsh"
	$ZDOTDIR/lib/rezcompall.zsh
  )

Log 'Recompiling everything.'
for x ($exen) $=x 2>/dev/null

unset -f Log
cd $OPWD

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
