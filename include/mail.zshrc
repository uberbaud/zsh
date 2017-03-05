# @(#)[:(EFr+JJk5yp-%<&CtQpC: 2017/03/05 06:08:16 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

MAILCHECK=-1
MAIL_HOME="$XDG_CONFIG_HOME/mail"
MAILRC="$MAIL_HOME/mail.rc"
MBOX="$MAIL_HOME/mbox"
MAILDROP=/var/mail/$USER
NMH=$XDG_CONFIG_HOME/nmh
MH=$NMH/config
fold=( fold -s -w 78 )

typeset -x -m 'MAIL*' MBOX NMH MH

function mail { warn "Don't you mean %F{2}inc%f?"; }
function inc  { /usr/local/bin/inc -nochangecur; }
function prev { /usr/local/bin/prev | $fold | less; }
function n    { /usr/local/bin/next | $fold | less; }
function next { n $@; }
function s    { /usr/local/bin/show $@ | $fold | less; }


# Copyright (C) 2016 by Tom Davis <tom@greyshirt.net>.
