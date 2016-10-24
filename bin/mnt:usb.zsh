#!/usr/bin/env zsh
# $Id: mnt:usb.zsh,v 1.3 2016/10/05 07:11:24 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. "$USR_ZSHLIB/common.zsh"

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


# Notes {{{1
# use `sysctl -n hw.disknames` to get disk ids of the form:
#   |sd0:0ed5723d61629b11,sd1:,sd2:610447cb57a9737c

# possibly, if at all useful, though maybe not, use
# `usbdevs -d | awk -F': ' '/^ *umass/ {print pln;} {pln=$2}'
# to list names of attached devices in the form of
#   |Clip Jam, SanDisk
#   |External USB 3.0, TOSHIBA
#

# use `doas disklabel sd1`, `doas disklabel sd2`, etc for each of the 
# discovered attached drives
# (hint, in '/etc/doas.conf' allow those exact command and args without 
# a password)
# `doas disklabel sd1 | awk '/^label: / {printf( "%s\t",$2,substr($0,8
# );} '
#}}}1

:rootness:init

typeset -a fatopts=( #{{{1
	-t msdos
	-s			#skip if already mounted, though we tried that already
	-o rw,noexec,nosuid,-g=$USER,-u=$USER
  ) #}}}1
typeset -a ffsopts=( #{{{1
	-t ffs
	-s
	-o rw,noexec,nodev,sync,softdep
  ) # }}}1
function mnt-fs {
	typeset -- dev=/dev/$1
	typeset -- mntpnt=/vol/$2
	shift 2

	df | egrep -q "^$dev " && return 0

	[[ -d $mntpnt ]]|| :rootness:cmd mkdir $mntpnt
	:
	on-error {
		-warn "Could not %Tmkdir%t %S${$mntpnt:gs/%/%%}%s."
		return 1
	}
	echo mount $@ $dev $mntpnt
	:rootness:cmd mount $@ $dev $mntpnt
	on-error {
		-warn "Could not %Tmount%t %S${dev:gs/%/%%}%s."
		#:rootness:cmd rmdir $mntpnt
		return 1
	}
	-notify "Mounted %S${dev:gs/%/%%}%s at %S${mntpnt:gs/%/%%}%s."
}

typeset -a awkpgm=()
awkpgm=(
	'/^label: /'		'{print substr($0,8);}'
	'/^  [abd-p]:/'		'{print $1,$4;}'
  )
function mnt-drv {
	typeset -- dev=$1
	typeset -- id=${2:-}
	typeset -a diskinfo=()
	doas disklabel $dev | awk "$awkpgm" | :assign diskinfo

	typeset -- label=$diskinfo[1]; shift diskinfo
	[[ $label =~ '[[:space:]]+$' ]]&& label=${label:0:$MBEGIN-1}

	(($#diskinfo==1))|| { -warn 'Too many drives, bailing.'; return 1; }

	typeset -- part=${diskinfo[1]%: *}
	typeset -- fstype=${diskinfo[1]#*: }

	case $fstype in
		'MSDOS')	mnt-fs $dev$part $label $fatopts;				;;
		'4.2BSD')	mnt-fs $dev$part $label $ffsopts;				;;
		*)			-warn "Unknown type <${fstype:gs/%/%%}>.";		;;
	esac
}

typeset -a disknames=( ${(s.,.)$( sysctl -n hw.disknames )} )
for d in $disknames; do
	[[ $d =~ '^sd0:' ]]&& continue
	mnt-drv ${d%%:*} ${d#*:}
done

:rootness:finit



# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
