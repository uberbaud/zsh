# @(#)[:u0r)IAiXI>A&Rwg0i@R&: 2017/07/22 17:31:19 tw@csongor.lan]
# Simple tools to handle common needs (TODO+/notes+) quickly

bindkey -N vitextblock viins
bindkey -M vitextblock $'\r' vi-open-line-below
bindkey -M vitextblock $'\t' self-insert
bindkey -M vitextblock $'\x04' accept-line

function note {
	[[ -d NOTES/RCS ]]|| {
		mkdir -p NOTES/RCS || die 'Could not mkdir %BNOTES%b.'
	  }
	local q=( NOTES/[0-9]*([-1]) )
	local seqnum=$(($q[1]+1))
	local filename=NOTES/$seqnum.note
	touch $filename
	[[ -s $filename ]]&&
		die "Unexpectedly, %B${filename:gs/%/%%}%b exists."
	echo 'working' >$filename


}


# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab
