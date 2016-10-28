# @(#)[wraps-end.zshrc 2016/08/12 08:04:17 tw@csongor.lan]
# vim: ft=zsh tabstop=4 textwidth=72 noexpandtab

for f in ${(k)WRAP_COMMANDS}; do
	typeset -- finish=' $@'
	[[ ${WRAP_COMMANDS[$f]} =~ '\$@' ]] && finish=''

	eval "$f () { ${WRAP_COMMANDS[$f]}${finish}; }";
done


# Copyright (C) 2015 by Tom Davis <tom@greyshirt.net>.
