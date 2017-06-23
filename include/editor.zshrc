# @(#)[:zXW8*x@nISk=TD=$Tsig: 2017/06/20 05:01:03 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

export EDITOR=${SYSLOCAL}/bin/vim
export MYVIM=${XDG_CONFIG_HOME}/vim
export MYVIMRC=${MYVIM}/vimrc
export VIMINIT="so $MYVIMRC"

# override general view without (re)moving anything so any system 
# expectations are not mishandled.
function view { #{{{1
	typeset -a settings=(
		nowrap
		nolist						# don't show tabs, newlines, etc
		nonumber norelativenumber	# no numbering lines
		colorcolumn=				# no highlighting a margin column
		conceallevel=2				# show cchar but mostly hide stuff
		concealcursor=nc			# hide concealables when navigating
	  )
	$EDITOR -MR -c ":set $settings" -- $@
} #}}}1
function r { #{{{1
	declare -- readme
	if (( $# > 0 )); then
		[[ $1 == '-h' ]] && usage '%Tr%t [-h|%Ufile%u]'
		readme=$1
	else
		declare -a readmes=( (#i)readme{.m{d,arkdown},}*(N) )
		(( $#readmes )) || die 'No README found.'
		readme=${readmes[1]}
	fi
	view $readme
  } #}}}1

# `r` is a zsh builtin related to fc (the history channel), so we need 
# to remove that completion definition.
compdef -d r


# Copyright © 2015,2016 by Tom Davis <tom@greyshirt.net>.
