# $Id: system.zshrc,v 1.7 2016/09/22 04:06:22 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

function pkg { # {{{1
	(($#))|| set help
	typeset -- AsRoot='/usr/bin/doas'
	typeset -- osv=$( uname -r )
	typeset -- cmd=$1
	shift
	typeset -- binpath="/usr/sbin"
	typeset -- bin="$binpath/pkg_${cmd}"

	typeset -- record=false
	case $cmd in
		add) 		$AsRoot $bin -i $@; record=true				;;
		check)		$AsRoot $bin $@;							;;
		delete)		$AsRoot $bin $@; record=true				;;
		installed)	$binpath/pkg_info -mz;						;;
		grep|query)
			typeset -- ndx="$HOME/.local/pkg-info/v${osv}/v${osv}.ndx"
			perl -ne "print if m/$1/;" $ndx | column -s $'\t' -t
			;;
		-h|--help|help)
			(($#))&& {
				cmd=$1; shift
				bin="${bin%_*}_$cmd"
				if [[ -x $bin ]]; then
					$bin -h
				else
					die "No help for %T${cmd:gs/%/%%}%t."
				fi
				return
			}
			typeset -- T=$'\e[32m'
			typeset -- S=$'\e[35m'
			typeset -- U=$'\e[4m'
			typeset -- N=$'\e[0m'
			cat <<----
			  ${T}pkg${N} ${S}cmd${N} ${U}args...${N}
			      performs pkg_${S}cmd${N}, possibly using ${T}doas${N},
			      possibly logging the action.
			  ${T}pkg grep${N} ${S}regex${N}
			  ${T}pkg query${N} ${S}regex${N}
			      performs a ${B}perl5 regex${N} search on the index file
			      example: ${T}pkg query '\\b(?^i:lisp)\\b'${N}
			      performs a case insensitive word bounded search for
			          ${S}lisp${N}.
			  ${T}pkg installed${N}
			      lists manually installed packages in a format which can be
			      used by ${T}pkg_add -l${N} to do a best effort with flavors
			      but not hampered by version.
			---
			;;
		*)
			[[ -x $bin ]]|| die "Unknown command %S${cmd:gs/%/%%}%s."
			$bin $@
	esac

	$record && print $cmd $@ >> $HOME/hold/$osv/pkg.log
}; # }}}1
function rcctl { # {{{1
	doas /usr/sbin/rcctl $@
	[[ ${1:-DONT} =~ '(en|dis)able|order' ]]&& {
		print -r -- $?':' $@ >> $HOME/hold/$(uname -r)/rcctl.log
	}
} #}}}1

declare -a	pkg_inet_host=(
		'ftp://ftp4.usa.openbsd.org'	# nyc
		'http://mirrors.nycbug.org'		# nyc
		'ftp://filedump.se.rit.edu'		# rochester
		'ftp://mirrors.nycbug.org'		# welcome banner causes problems
		'ftp://openbsd.mirror.frontiernet.net' # rochester
		'ftp://mirror.jmu.edu'			# harrisonburg, va
	)
declare -- os_version="$( /usr/bin/uname -r )"
declare -- cpu_type="$( /usr/bin/uname -m )"
declare --	pkg_inet_path="pub/OpenBSD/$os_version/packages/$cpu_type"

PKG_PATH="${pkg_inet_host[1]}/${pkg_inet_path}"
CVSROOT=anoncvs@anoncvs4.usa.openbsd.org:/cvs
export PKG_PATH CVSROOT

