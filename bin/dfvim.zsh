#!/usr/local/bin/zsh
# @(#)[:%DIN7z;r!@#QZ%A2a)=H: 2017/06/13 21:03:39 tw@csongor.lan]

HOME=${(@)${(s.:.)$(getent passwd $(logname))}[6]}

. $USR_ZSHLIB/common.zsh || exit 86
:needs omenu vim sakura

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [%Ufile name%u]"
	'  Edits a file in %BDistraction Free%b mode'
	'  If no %Ufile name%u is given, uses %B.local/disfree/*%b'
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

typeset -- dfPath=${XDG_DOCUMENTS_DIR}/disFree
typeset -- fName="$*"

[[ $fName == */* ]]&& { # there's a directory attached, so use that
	dfPath=${fName%/*}
	fName=${fName##*/}
}

[[ -a $dfPath ]]|| {
	mkdir -p $dfPath ||
		-die 'Could %Bnot%b %Tmkdir%t DF path:' "    %U$dfPath%u"
  }
[[ -d $dfPath ]]|| -die "%U$dfPath%u is %Bnot%b a directory."
cd $dfPath || -die 'Could %Bnot%b %Tcd%t to:' "    %U$dfPath%u"

readonly dfVimRc=${XDG_CONFIG_HOME}/vim/disfree.rc
[[ -a $dfVimRc ]]|| -die "Could not find %B$dfVimRc%b"
[[ -f $dfVimRc ]]|| -die "%B$dfVimRc%b is not a file."

readonly sakuraHome=${XDG_CONFIG_HOME}/sakura
[[ -a $sakuraHome ]]|| -die "Could not find %B$sakuraHome%b"
[[ -d $sakuraHome ]]|| -die "%B$sakuraHome%b is not a directory."

readonly sakuraRc=disFree.conf
[[ -a ${sakuraHome}/$sakuraRc ]]|| -die "Could not find %B$sakuraRc%b"
[[ -f ${sakuraHome}/$sakuraRc ]]|| -die "%B$sakuraRc%b is not a file."

[[ -n $fName ]]|| {
	fName=$( umenu *(.) '<new>' )
	[[ -n $fName ]]|| { -warn Quitting; return 0; }
}

[[ $fName == '<new>' ]]&& {
	read -r fName'?  New file name: '
  }
[[ -n $fName ]]|| { -warn Quitting; return 0; }

[[ $fName == *.* ]]|| fName=$fName.rem

typeset -a term_opts=(
	--config-file $sakuraRc

	# try everything to make it fullscreen
	--name dfvim	# for evilwm to set fullscreen
	--class dfVim	# for evilwm to set fullscreen

	####### THESE DON'T WORK!
	#--maximize
	#--fullscreen
	#--geometry ${(j:x:)${(@)$(xdotool getdisplaygeometry)}}+0+0

	####### THESE WORK BUT DON'T FIT THE WINDOW TO THE SCREEN!
	#--columns	83
	#--rows		25

	# vim options
	#-e "v  '$fName' '${fName#.rem}'"
	-e "v '$fName'"
  )

[[ -a $fName ]]|| new -n $fName ${fName%.*}

export VIMINIT="so $dfVimRc"
sakura $term_opts 1>>${HOME}/log/disFree.log 2>&1 &!

# vim: ts=4 filetype=zsh noexpandtab
