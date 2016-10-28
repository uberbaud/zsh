#!/usr/bin/env zsh
# @(#)[term-colors.zsh 2016/10/25 07:09:12 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

typeset -i i j n
# standard ansi-ish colors
for j in 0 8; do
	printf '\n    '
	for i in {0..7}; do
		printf '\e[48;5;%dm %0.3d \e[0m' $n $n
		n=$((n+1))
	done
done
printf '\n'

# big color chart
for j in {1..36}; do
	printf '\n         '
	for i in {1..6}; do
		printf '\e[48;5;%dm %0.3d \e[0m' $n $n
		n=$((n+1))
	done
done
printf '\n'

# greyscale
for j in 1 2 3; do
	printf '\n    '
	for i in {1..8}; do
		printf '\e[48;5;%dm %0.3d \e[0m' $n $n
		n=$((n+1))
	done
done
printf '\n'

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
