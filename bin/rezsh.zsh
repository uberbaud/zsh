#!/usr/bin/env zsh
# @(#)[:gfCr+Ry[rezsh.zsh 2016/10/27 04:49:41 tw@csongor.lan]<6wXwzgmasGj: 2016/12/09 06:50:49 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh

cd $ZDOTDIR

typeset -- funclib='usrfuncs.zwc'
zcompile -t $funclib | while read item; do
	[[ $item =~ '^functions/' ]]|| continue
	item=${item:$MEND}
	(($+functions[$item]))&& unfunction $item
done

zcompile -Uz $funclib functions/*(.)
autoload -Uz functions/*(.:t)

$ZDOTDIR/bin/parse-twrc.zsh
zcompile -RU .include
zcompile -Uz .zshrc

# Copyright (C) 2016 by Tom Davis <tom@greyshirt.net>.
