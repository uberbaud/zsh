#!/usr/bin/env zsh
# @(#)[:!SUquEVJKu3pGF)gwq~x: 2017/03/05 06:21:12 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

printf '  \e[47;38m    \\e[#m   \\e[3#m  \\e[4#m  \e[0m\n'
FMT=' %3d: \e[%dm ATTR \e[0m  \e[3%dm FORE \e[0m  \e[4%dm BACK \e[0m\n'
for i in {1..7}; do
	printf $FMT  $i $i $i $i
done


# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
