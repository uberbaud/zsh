#!/usr/bin/env zsh
# @(#)[:V8Sv{(5a-neqfLC!*jw#: 2017/06/26 03:07:12 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86

cd $ZDOTDIR

typeset -- funclib='usrfuncs.zwc'
[[ -f $funclib ]]&& zcompile -t $funclib | while read item; do
		[[ $item =~ '^functions/' ]]|| continue
		item=${item:$MEND}
		(($+functions[$item]))&& unfunction $item
	done

zcompile -Uz $funclib functions/*(e:'[[ -f $REPLY ]]':)
autoload -Uz functions/*(e:'[[ -f $REPLY ]]'::t)

$ZDOTDIR/bin/parse-twrc.zsh
zcompile -RU .include
zcompile -Uz .zshrc

# Copyright (C) 2016 by Tom Davis <tom@greyshirt.net>.
