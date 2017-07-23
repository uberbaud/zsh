# @(#)[:u0r)IAiXI>A&Rwg0i@R&: 2017/07/23 05:13:19 tw@csongor.lan]
# Simple tools to handle common needs (TODO+/notes+) quickly

bindkey -N vitextblock viins
bindkey -M vitextblock $'\r' vi-open-line-below
bindkey -M vitextblock $'\t' self-insert
bindkey -M vitextblock $'\x04' accept-line

function note {
set -x
	[[ -d NOTES/RCS ]]|| {
		mkdir -p NOTES/RCS || die 'Could not mkdir %BNOTES%b.'
	  }
	cd NOTES
	local TMPFILE="$( mktemp note-XXXXXXXXX )"
	local Q=( [0-9]*.note(N) )
	integer seqnum=0
	(($#Q))&& {
		[[ $q =~ '^[0-9]+' ]]|| die 'IMPOSSIBLE THING #1'
		seqnum=$((MATCH))
	  }
	integer tries=5
	while ((tries--)); do
		((seqnum++))
		ln $TMPFILE $seqnum.note && break
		octet="$(dd bs=1 count=1 status=none if=/dev/urandom)"
		sleep 0.$(printf '%03d' \'$octet)
	done
	((tries))|| die 'Could not create %Bnote%b.'
	new -nz note "$@"
	pbpaste >$seqnum.note
	(($#))|| v -m'.' $seqnum.note
	cd ..
}


# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab
