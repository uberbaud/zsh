#!/usr/bin/env zsh
# @(#)[ask-first.zsh 2016/10/25 07:07:16 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86

typeset -A cmds;
cmds=(
	ssh		/usr/bin/ssh
	scp		/usr/bin/scp
	sftp	/usr/bin/sftp
	rsync	$SYSLOCAL/bin/rsync
  )

(($#))|| -usage 'Missing %Tcmd%t, one of' "  %S${(@k)^cmds}%s"
typeset -- cmd=$1

typeset -- bin=${cmds[$cmd]:-}
[[ -n $bin ]]|| -die "Can't handle command <%T$cmd%t>."

# test for possible installed identities
if ! /usr/bin/ssh-add -l > /dev/null; then
	printf '\e[s ==> Gather passphrase\n'
	# force an x-window
	/usr/bin/ssh-add < /dev/null
	# restore cursor and blank intermediate
	printf '\e[u\e[K\e[0J'
fi

shift
exec $cmd $@


# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
