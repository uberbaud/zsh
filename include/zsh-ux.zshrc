# $Id: zsh-ux.zshrc,v 1.17 2016/10/23 22:51:00 tw Exp $
# vim: tabstop=4 filetype=sh nowrap

HISTFILE=$XDG_DATA_HOME/zsh/histfile
HISTSIZE=254
SAVEHIST=1000

# ─────────────────────── BEGIN: vi key bindings ────
bindkey -v
autoload -Uz edit-command-line			\
	&& zle -N edit-command-line			\
	&& bindkey -M vicmd v edit-command-line
[[ $? -eq 0 ]] || print -Pu 2 '%F{1}FAILED TO LOAD%f: %Uedit-command-line%u'
# ─────────────────────── END: vi key bindings ──────

# ─────────────────────── BEGIN: completion ────
zstyle :compinstall filename "$XDG_CONFIG_HOME/zsh/zshrc"
zstyle ':completion:*' menu select
autoload -Uz compinit && compinit
# we have our own new, so don't want their completion! Plus, `fstat` 
# tries to do some unOpenBSDish stuff, so completion doesn't work, get 
# rid of that
compdef -d new fstat
# let's see what `completion` is doing
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '  %K{194}%F{28}▌%f% %d %F{28}▐%f%k'
zstyle ':completion:*:messages' format '%B%d%b'
zstyle ':completion:*:warnings' format '%F{1}No matches for:%f %B%d%b'
zstyle ':completion:*' group-name ''
# ─────────────────────── END: completion ──────

# ─────────────────────── BEGIN: prompt  ──── {{{1
declare -gi errno=0

function set_window_title { print -Pn $'\e]0;%M (%d)\a'; }
chpwd_functions+=( set_window_title )
set_window_title

function handle_errno {
	if (( errno )); then
		psvar[1]="$errno"
	else
		psvar[1]=''
	fi
	errno=0
  }
precmd_functions+=( handle_errno )

set_prompt # declared in $HOST.zshrc

# ─────────────────────── END: prompt  ────── }}}1

function clear { print -f '\e[0;0H\e[2J\e[3J'; }

