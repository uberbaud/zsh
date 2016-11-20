# @(#)[:r[wraps-end.zshrc 2016/08/12 08:04:17 tw@csongor.lan]Oq`sYv$NUs[wraps-end.zshrc 2016/08/12 08:04:17 tw@csongor.lan]eoxOB;y: 2016/11/20 23:44:35 tw@csongor.lan]
# vim: ft=zsh tabstop=4 textwidth=72 noexpandtab

for fname fbody in ${(kv)WRAP_COMMANDS}; do
	typeset -- finish=' $@'
	[[ $fbody =~ '\$@' ]] && finish=''

	cmd=${${(z)$fbody}[1]}
	[[ $cmd == $AsRoot ]]&& cmd=${${(z)$fbody}[2]}

	whence $cmd >/dev/null || {
		printf '  \e[38;5;172mwarning\e[0m: No such cmd \e[2m%s\e[0m\n' $cmd
		continue
	}

	eval "$fname () { ${fbody}${finish}; }";
done


# Copyright (C) 2015 by Tom Davis <tom@greyshirt.net>.
