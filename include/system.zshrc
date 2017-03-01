# @(#)[:R88m?#+cJ1w!Kr4B,0Ax: 2017/02/28 01:42:52 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

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

