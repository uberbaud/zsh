#!/usr/bin/env zsh
# $Id: parse-twrc.zsh,v 1.4 2016/10/27 04:45:59 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

. $USR_ZSHLIB/common.zsh

typeset -- incRC=$ZDOTDIR/includes.rc
typeset -- incDIR=$ZDOTDIR/include
typeset -- incGENERATE=$ZDOTDIR/.include

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t"
	'  '
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
while getopts ':h' Option; do
	case $Option in
		h)	-usage $Usage;										;;
		\?)	-die "Invalid option: '-$OPTARG'.";					;;
		\:)	-die "Option '-$OPTARG' requires an argument.";		;;
		*)	bad_programmer "$Option";							;;
	esac
done
# cleanup
unset -f bad_programmer
# remove already processed arguments
shift $(($OPTIND - 1))
# ready to process non '-' prefixed arguments
# /options }}}1

[[ -f $incRC ]]||	-die 'Could not find %S$ZDOTDIR%s%B/includes.rc%b.'
[[ -r $incRC ]]||	-die 'Could not read %S$ZDOTDIR%s%B/includes.rc%b.'
[[ -d $incDIR ]]||		-die 'Could not find directory %S$ZDOTDIR/include%s.'
[[ -r $incDIR ]]||		-die 'Can not read directory %S$ZDOTDIR/include%s.'
[[ -x $incDIR ]]||		-die 'Can not search directory %S$ZDOTDIR/include%s.'

typeset -i incLINENO=0

typeset -a twords=()
function inc-parse {
	incLINENO=$((incLINENO+1))
	twords=()
	typeset -i i
	# cut off the comment
	for w in ${(z)1:-}; do
		[[ $w =~ '^;' ]]&& break
		twords+=( $w )
	done
	return 0
}

exec {fINC}<$incRC

typeset -- trycode itworks ua
typeset -a codematches=()
typeset -- keycode=''
typeset -A codework=()
while read -ru $fINC ln; do
	inc-parse $ln
	(($#twords))|| continue
	[[ $twords[2] == '=' ]]|| break
	trycode=$twords[1]
	(($#trycode!=1))&& -die "Bad %skeycode%s assignment line %B$incLINENO%b."
	codework[$trycode]=$((${codework[$trycode]:-0}+1))

	itworks=false
	for ua in $twords[3,-1]; do
		# require match on user portion if it was given
		[[ $ua =~ '@' ]]&& { [[ ${ua%@*} =~ $USER ]]|| continue; }
		# get rid of already matched user@ portion
		ua=${ua##*@}
		[[ $HOST. =~ "^${ua:gs/./\\.}\." ]]|| continue
		itworks=true
		codematches+=( "$ua (ln $incLINENO)" )
	done
	$itworks && {
		keycode+=$trycode
	}
done

(($#keycode>1))&&	-die 'Multiple %Skeycodes%s matched:' $codematches
(($#keycode))||		-die "No match %Skeycode%s match for %S${USER:gs/%/%%}@${HOST:gs/%/%%}%s."
for k v in ${(kv)codework}; do
	((v==1))||		-die "Keycode %S${k:gs/%/%%}%s was used %B$v%b times."
done

typeset -a validcodes=( ${(k)codework} )
codework=() # reset

typeset -- smashed fileword
typeset -- fail=false
typeset -- badstuff=()
typeset -a includeFiles=()
typeset -a excludeFiles=()
typeset -a ziphelp=( 1 )
typeset -- cre="\\Q$keycode" # allow keycode to be a pcre metacharacter
while :; do
	(($#twords))&& {
		fileword=${(e)${twords[-1]}}
		smashed=${(j::)twords[1,-2]}
		if [[ $smashed =~ $cre ]]; then
			includeFiles+=( $fileword )
		else
			excludeFiles+=( $fileword )
		fi
		codework+=( ${${(s::)smashed}:^^ziphelp} )
		badstuff=( ${${(s::)smashed}:|validcodes} )
		# the following doesn't play well with ARITHMETIC EXPANSION
		(($#badstuff)) && {
			badstuff=( ${(qq)badstuff:gs/%/%%} )
			-warn "line $incLINENO: bad keycode %B$badstuff%b"
			fail=true
		}
	}
	read -ru $fINC ln || break
	inc-parse $ln
done

exec {fINC}>&-

typeset -a usedcodes=( ${(k)codework} )
badstuff=( ${validcodes:|usedcodes} )
(($#badstuff)) && {
	badstuff=( ${(qq)badstuff:gs/%/%%} )
	-warn "These codes were set but unused: %B$badstuff%b"
}
$fail && {
	-die "Bad keycodes are fatal."
}

typeset -a actualFiles=( ${$(echo $incDIR/*.zshrc):r:t} )
typeset -a mentionedFiles=( $includeFiles $excludeFiles )

badstuff=( ${actualFiles:|mentionedFiles} )
(($#badstuff)) && {
	badstuff=( ${(qq)badstuff:gs/%/%%} )
	-warn 'Existing files not mentioned: ' "    %B${^badstuff[@]}%b"
}

badstuff=( ${mentionedFiles:|actualFiles} )
(($#badstuff)) && {
	badstuff=( ${(qq)badstuff:gs/%/%%} )
	-die 'Non-existent files mentioned for inclusion:' "    %B${^badstuff[@]}%b"
}

typeset -- filename
>$incGENERATE {
	# header
	printf '#### GENERATED FILE ####\n'
	printf '# generated by %s\n' ${(D)0}
	printf '#           on %s\n' "$(date -u +'%Y-%m-%d %H:%M:%S Z')"
	printf '#           using input file %s\n' ${(D)incRC}
	printf '# ZDOTDIR = %s\n\n' ${(D)ZDOTDIR}
	# preamble
	printf 'typeset -ga finit=()\n'
	printf 'function FINIT: { finit+=( "$@" ); }\n'

	# includes
	for f in $includeFiles; do
		filename=$incDIR/$f.zshrc
		[[ -r $filename ]]|| -die "Could not read %S${filename:gs/%/%%}%s."
		printf '\n#===%s\n' ${(l:62::=::| :)f}' |======='
		cat $incDIR/$f.zshrc
	done

	# finalize and cleanup
	printf '\nunset -f FINIT:\n'
	printf 'for statement in $finit; do\n'
	printf '\t${=statement}\n\t(( ${+functions[$statement]} )) && unset -f $statment\n'
	printf 'done\nunset finit\n\n'
}

zcompile -R $incGENERATE


true # end on a good note

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
