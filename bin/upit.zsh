#!/usr/bin/env zsh
# @(#)[upit.zsh 2016/10/25 07:09:12 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86

typeset -r SRMS='%USource Revision Management System%u'
typeset -- bin="$SYSLOCAL/bin"

# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t"
	"  Calls the appropriate $SRMS"
	'  upgrade/pull command.'
	'  Supports:'
	'    Bazaar (%Tbzr%t),'
	'    Concurrent Versisons System (%Tcvs%t),'
	'    Darcs (%Tdarcs%t),'
	'    Git (%Tgit%t),'
	'    Fossil (%Tfossil%t),'
	'    Mercurial (%Thg%t),'
	'    Subversion (%Tsvn%t), and'
	'    %Trsyncup.sh%t'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
typeset -- verbose=false
while getopts ':hv' Option; do
	case $Option in
		h)	-usage $Usage;										;;
		v)	verbose=true;										;;
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
function versctrl { # {{{1
	typeset -- versctrl_dscr=${1:?No VersCtrl description passed.}
	typeset -- versctrl_cmd=${bin}/${2:?No VersCtrl command passed.}
	[[ -a $versctrl_cmd ]]|| -die "Can not find command %T${1:gs/%/%%}%t."
	[[ -x $versctrl_cmd ]]		\
		|| -die "You do not have execute permission for ${1:gs/%/%%}%t."

	-notify "This is a %B${versctrl_dscr:gs/%/%%}%b repository."
	shift; shift;
	for sub_cmd in $argv; do
		-notify "Trying %T${versctrl_cmd:gs/%/%%} ${sub_cmd:gs/%/%%}%t."
		$versctrl_cmd ${(z)sub_cmd}
		on-error "Did not update repository."
	done
} # }}}1
function show-possibilities-and-die { # {{{1
	typeset -a msg=( "Did not find a supported $SRMS." )
	setopt null_glob
	typeset -a doteds=( .* )
	(($#doteds))|| -die $msg 'There are %Bno dotted files%b.';

	msg+=( '  possible %Ssrms%s control directories:' )
	for potential in $doteds; do
		[[ $potential = '.' ]]&& continue
		[[ $potential = '..' ]]&& continue
		[[ -d $potential ]]&& msg+=( "      %B${potential:gs/%/%%}%b" )
	done
	-die $msg
} # }}}1

typeset -a SRMSc=()
for d in bzr cvs darcs git hg svn; do
	[[ -d .$d ]]&& SRMSc+=($d)
done
for f in fslckout rsyncup; do [[ -a .$f ]]&& SRMSc+=($f); done
(($#SRMSc))|| show-possibilities-and-die
(($#SRMSc==1))		\
	|| -die 'Multiple %Ssrms%s possibilities:' "  %B${(@)^SRMSc:gs/%/%%}%b"
[[ $SRMSc[1] == git && -f .gitmodules ]]&& SRMSc=( gitmodules )


typeset -- CVS='Concurrent Versisons System'
typeset -- srms=${SRMSc[1]}
typeset -- modcmds='submodule update --remote'
case $srms in
  # cntrl   cmd      description    bin     cmd(s)
	git)		versctrl Git			$srms	pull;				;;
	gitmodules)	versctrl Git+Modules	git		pull $modcmds;		;;
	fslckout)	versctrl Fossil			fossil	pull 'co --latest';	;;
	svn)		versctrl Subversion		$srms	update;				;;
	hg)			versctrl Mercurial		$srms	pull update;		;;
	cvs)		versctrl $CVS			$srms	update;				;;
	bzr)		versctrl Bazaar			$srms	update;				;;
	darcs)		versctrl Darcs			$srms	update;				;;
	rsyncup)
				bin="$USRBIN"
				versctrl RSyncUp		$srms	update
				;;
	*) -die "I can't handle %B${SRMSc[1]:gs/%/%%}%b.";		;;
esac


# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
