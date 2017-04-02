#!/usr/bin/env zsh
# @(#)[:G*EpG}m8g31H09A=,9||: 2017/03/20 23:49:06 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86

typeset -- gdrive=$HOME'/hold/gdrive'


# Usage {{{1
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [%Ulist of google drives%u]"
	"  Sync given Google Drives."
	"    If no list of drives is given, all drives are synced."
	"    Drives are those in (%S~${${gdrive/#$HOME}:gs/%/%%}/*%s)"
	"%T${this_pgm:gs/%/%%} -l%t"
	'  List available drives'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
list_accts=false
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
while getopts ':lh' Option; do
	case $Option in
		l)	list_accts=true;									;;
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

[[ -d $gdrive ]]|| -die "No such directory %S${gdrive:gs/%/%%}%s."

cd $gdrive
on-error -die "Could not %Tcd%t to %S${gdrive:gs/%/%%}%s."

function list-accounts {
	local accts=( *(/) )
	-notify 'Available accounts are:' "%S${(@)^accts:gs/%/%%}%s"
}

function sync-drive {
	$SYSLOCAL/bin/grive "$@"
	on-error {
		-warn "There were problems syncing %S${1:gs/%/%%}%s."
		return 1
	  }

	return 0
}

function one-drive {
	[[ -d $1 ]]|| {
		-warn "No such account directory %S${1:gs/%/%%}%s."
		list-accounts
		return 1
	  }

	local OPWD=$PWD
	cd $1
	on-error {
		-warn "Could not %Tcd%t to %S${gdrive:gs/%/%%}%s."
		return 1
	  }

	if [[ -f .grive ]]; then
		-notify "Syncing %S${1:gs/%/%%}%s."
		sync-drive
	else
		-notify "Syncing %Bnew drive%b %S${1:gs/%/%%}%s."
		-warn   'Before going to listed url, %Blog in%b to account at'
				'    %Shttps://accounts.google.com/ServiceLogin%s'
				'with user name'
				"    %S${1:gs/%/%%}%s"
		sync-drive --auth
	fi

	cd $OPWD
	on-error -die "%BWEIRD!%b Could not return to %S${gdrive:gs/%/%%}%s."
}

$list_accts && { list-accounts; return 0; }

(($#))|| set *(/)	# allow user supplied drives only option
for d ($@) one-drive $d

# Copyright © 2017 by Tom Davis <tom@greyshirt.net>.
