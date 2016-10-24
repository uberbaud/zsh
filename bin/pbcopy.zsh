# $Id: pbcopy.zsh,v 1.2 2016/05/26 05:38:18 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

emulate -L zsh

$SYSLOCAL/bin/xclip -selection clipboard -in
