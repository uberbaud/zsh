#!/usr/bin/env zsh
# $Id: rezsh.zsh,v 1.14 2016/10/23 03:42:19 tw Exp $
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

cd include
function rezcmpl { -notify "recompiling $1"; zcompile -Uz $1; }
for z in *.zshrc(.); do [[ $z -nt $z.zwc ]]&& rezcmpl $z; done
cd ..
zcompile -Uz .zshrc

cd $save_wd

# warn of any includes not included or noted with a comment
# get everything included with a `.` or commented out with a `#` instead
typeset -a awkpgm=(
	'/^\. \$ZDOTDIR\/include\//'
		'{ print "A" substr($2,18); }'
	'/^# \$ZDOTDIR\/include\//'
		'{ print "B" substr($2,18); }'
  )
typeset -a incs=( $( awk "$awkpgm" $ZDOTDIR/zsh.rc ) )
# sort <- expand variables etc, just like the shell will do
incs=( ${(o)${(e)incs}} )
typeset -i first_commented=${incs[(i)B*]}

# gather the commented to another variable (igns)
typeset -a igns=( $incs[first_commented,-1] )
# delete the commented bits
incs[$first_commented,-1]=()

# remove the prefix character indicating comment or source ([AB])
incs=( ${incs#A} )
igns=( ${igns#B} )

typeset -a files=( $ZDOTDIR/include/*.zshrc(:t) )

typeset -a s1=( ${(0)"$( :set:A-minus-B incs files )"} )
(( $#s1 )) && -warn "%F{4}Sourced but no files %f" $s1

# exists_not_sourced
typeset -a s2=( ${(0)"$( :set:A-minus-B files incs )"} )
s2=( ${(0)"$( :set:A-minus-B s2 igns )"} )
(( $#s2 )) && -warn "%F{4}Include files not sourced%f" $s2

# commented_doesnt_exist
typeset -a s3=( ${(0)"$( :set:A-minus-B igns files )"} )
(( $#s3 )) && -warn "%F{4}Commented but no file%f" $s3

. $ZDOTDIR/.zshrc


# Copyright (C) 2016 by Tom Davis <tom@greyshirt.net>.
