# @(#)[:KvI<T|sO={#X{JT*VLOh: 2017/03/05 05:50:15 tw@csongor.lan]
# vim: ft=zsh tabstop=4 textwidth=72 noexpandtab

whence $AsRoot >/dev/null || {
	printf '  \e[38;5;172mwarning\e[0m: \e[35mAsRoot\e[0m is improperly set to \e[32m%s\e[0m\n' $AsRoot
}

typeset +t allgood cmd fbody finish fname
for fname fbody in ${(kv)WRAP_COMMANDS}; do
	allgood=true
	# append args alias like, unless they're already specified
	finish=' $@'
	[[ $fbody =~ '\$@' ]] && finish=''

	# check for command existence
	cmd=${${fbody:s/;/ }[(w)1]}
	if [[ $cmd == $AsRoot ]]; then
		# special handling for AsRoot
		cmd=$fbody[(w)2]
		[[ -f $cmd ]] || allgood=false
	else
		whence $cmd >/dev/null || allgood=false
	fi
	$allgood || {
		printf '  \e[38;5;172mwarning\e[0m: No such cmd `\e[32m%s\e[0m`' $cmd
		printf '  Skipping wrapper \e[35m%s\e[0m\n' $fname
		continue
	} >&2

	eval "$fname () { ${fbody}${finish}; }";
done

unset allgood cmd fbody finish fname

# Copyright (C) 2015 by Tom Davis <tom@greyshirt.net>.
