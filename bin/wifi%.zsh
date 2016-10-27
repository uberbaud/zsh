#!/usr/bin/env zsh
# $Id: wifi%.zsh,v 1.3 2016/10/25 07:09:12 tw Exp $
# vim: filetype=bash tabstop=4 textwidth=72 noexpandtab

typeset -i signalstrength=0
# assignment to an integer typed variable performs shell arithmetic, and 
# ifconfig|egrep returns a value ending in a division remainder sign 
# (%), so provide a number for that will return 0-100 to be stored.
signalstrength=$(/sbin/ifconfig iwm0 | egrep -o '[0-9]+%' )128
echo $signalstrength

# Copyright (C) 2015 by Tom Davis <tom@greyshirt.net>.
