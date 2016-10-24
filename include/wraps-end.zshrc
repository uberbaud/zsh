# $Id: wraps-end.zshrc,v 1.3 2016/08/12 08:04:17 tw Exp $
# vim: ft=zsh tabstop=4 textwidth=72 noexpandtab

for f in ${(k)WRAP_COMMANDS}; do
	typeset -- finish=' $@'
	[[ ${WRAP_COMMANDS[$f]} =~ '\$@' ]] && finish=''

	eval "$f () { ${WRAP_COMMANDS[$f]}${finish}; }";
done


# Copyright (C) 2015 by Tom Davis <tom@greyshirt.net>.
