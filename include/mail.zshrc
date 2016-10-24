# $Id: mail.zshrc,v 1.10 2016/10/15 07:17:19 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

MAILCHECK=-1
MAIL_HOME="$XDG_CONFIG_HOME/mail"
MAILRC="$MAIL_HOME/mail.rc"
MBOX="$MAIL_HOME/mbox"
MAILDROP=/var/mail/$USER
NMH=$XDG_CONFIG_HOME/nmh
MH=$NMH/config
fold=( fold -s -w 78 )

FETCHMAILHOME=$XDG_CONFIG_HOME/fetchmail
#FETCHMAILUSER=tw
#FETCHMAIL_DISABLE_CBC_IV_COUNTERMEASURE
#FETCHMAIL_INCLUDE_DEFAULT_X509_CA_CERTS
#HOME_ETC

typeset -x -m 'MAIL*' MBOX NMH MH 'FETCHMAIL*'

function mail { warn "Don't you mean %F{2}inc%f?"; }
function inc  { $SYSLOCAL/bin/inc -nochangecur; }
function prev { $SYSLOCAL/bin/prev | $fold | less; }
function n    { $SYSLOCAL/bin/next | $fold | less; }
function next { n $@; }
function s    { $SYSLOCAL/bin/show $@ | $fold | less; }

# Copyright (C) 2016 by Tom Davis <tom@greyshirt.net>.
