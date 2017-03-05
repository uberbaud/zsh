#!/usr/bin/env zsh
# @(#)[:$G5da0Wndx}{ND`#mdhs: 2017/03/05 06:14:21 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

emulate -L zsh

typeset -- save_wd=$PWD
function TRAPEXIT { cd $save_wd; }

cd $USR_ZSHLIB

########################################################################
##############################################   COMMON FUNCTIONS   ####
########################################################################

# include any files on a per OS basis
typeset -- syslib=${(L)$(uname)}
typeset -a linked=()
[[ -d $syslib ]]&& {
	for f in $syslib/*; do
		typeset -- l=${f#$syslib/}
		ln -s $PWD/$f $l
		linked+=( $l )
	done
}
# plus all plain files without ANY extension
typeset -a funcs_to_compile=( *(.e:'[[ ! $REPLY == *.* ]]':) $linked )

print -Pu 2 ' %F{4}>>>%f Compiling:' $funcs_to_compile

zcompile -Uz common_funcs.zwc $funcs_to_compile

# remove now unnecessary soft linked files
(($#linked))&& rm $linked

########################################################################
##########################################   COMMON INCLUDE SCRIPT  ####
########################################################################


typeset -- loader='common.zsh'
print -Pu 2 " %F{4}>>>%f Writing new $loader"
rm -f $loader || {
	print -Pu 2 "%F{1}FAILED%f: Could not remove %B$loader%b."
	exit 1
}

typeset -a script_sh_opts=(
	bsd_echo			# require -e to handle escaped sequences
	extended_glob		#
	local_options		#
	local_patterns		#
	local_traps			#
	no_function_argzero	# $0 is always the name of the script
	no_hash_dirs		# only hash a command actually run
	no_mult_ios			# require `tee` don't use `zsh` multiple redirects
	no_unset			# fail on using unset variables
	pipe_fail			# don't set $?=0 just because rightmost succeeded
	re_match_pcre		# use pcre for [[ =~ ]] rather than posix extended
  )

typeset -a lines=(
	'# Generated by `rezcompall.zsh`. Any edits will be overwritten!'
	''
	'emulate -L zsh'	# resets to some defaults
	"setopt $script_sh_opts"
	''
	'fpath=( $USR_ZSHLIB/common_funcs.zwc $fpath )'
	"autoload -z -- $funcs_to_compile"
	''
	"alias on_error='((!\$?))||'"
	"alias on-error='((!\$?))||'"
	"alias if-no='((!\$?))||'"
	"alias if-yes='((\$?))||'"
  )
print -l "${lines[@]}" > $loader

print -Pu 2 " %F{4}>>>%f Compiling: $loader"
zcompile -Uz $loader

# Copyright (C) 2016 by Tom Davis <tom@greyshirt.net>.
