#!/usr/bin/env zsh
# @(#)[rezsh.zsh 2016/10/27 04:49:41 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh

typeset -- save_wd=$PWD
cd $ZDOTDIR

typeset -- funclib='usrfuncs.zwc'
typeset -- cfuncs=()
typeset -- fbody=''
zcompile -t $funclib | while read item; do
	[[ $item =~ '^functions/' ]]|| continue
	cfuncs+=( ${item:$MEND} )
done

(($#cfuncs))&& unfunction $cfuncs
zcompile -Uz $funclib functions/*(.)
autoload -Uz functions/*(.:t)

$ZDOTDIR/bin/parse-twrc.zsh
zcompile -RU .include
zcompile -Uz .zshrc

# Copyright (C) 2016 by Tom Davis <tom@greyshirt.net>.
