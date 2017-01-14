#!/usr/bin/env zsh
# @(#)[:V8Sv{(5a-neqfLC!*jw#: 2017/01/05 02:03:39 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86

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
