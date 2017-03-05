# @(#)[:tnqElT6adkcyZHp#8p|!: 2017/03/05 06:08:48 tw@csongor.lan]
# vim: tabstop=4 filetype=sh

# LOCALIZATION & STANDARDIZATION
LANG="en_US.UTF-8"

LC_ALL="en_US.UTF-8"
LC_CTYPE="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"

ISO_DATE='%Y-%m-%d %H:%M:%S %z'
ISO_WEEK='%G-W%V-%u'
	# %G - The 4-digit year corresponding to the ISO week number (%V). If
	# the ISO week number belongs to the previous or next year, that year
	# is used instead.

TZ='EST5EDT'
XCOMPOSEFILE=$XDG_CONFIG_HOME/x11/Compose.tw
GTK_IM_MODULE='xim'
QT_IM_MODULE='xim'
XMODIFIERS='@im=none'


typeset -x -m 'LC_*' -m 'ISO_*' TZ XCOMPOSEFILE '*_IM_MODULE' XMODIFIERS
