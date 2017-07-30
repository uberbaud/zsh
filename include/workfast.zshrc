# @(#)[:u0r)IAiXI>A&Rwg0i@R&: 2017/07/30 14:10:07 tw@csongor.lan]
# Simple tools to handle common needs (TODO+/notes+) quickly

bindkey -N vitextblock viins
bindkey -M vitextblock $'\r' vi-open-line-below
bindkey -M vitextblock $'\t' self-insert
bindkey -M vitextblock $'\x04' accept-line
bindkey -N vtxtblckcmd vicmd
bindkey -M vtxtblckcmd : beep

alias note='noglob note'
function note {
	local NOTES=$PWD OLDPWD=$PWD
	local noterepo=${HOME}/.local/sysdata/notes
	[[ $NOTES == $HOME ]]&& NOTES=${HOME}/docs/NOTES
	[[ -d $noterepo ]]|| {
		mkdir -p $noterepo ||
			die 'Could not mkdir %B${noterepo:gs/%/%%}%b.'
	  }
	[[ -d ${NOTES}/RCS ]]|| {
		mkdir -p ${NOTES}/RCS || die 'Could not mkdir %B${NOTES}%b.'
	  }
	cd ${NOTES}
	local TMPFILE="$( mktemp note-XXXXXXXXX )"
	local Q=( [0-9]*.note(N) )
	local seqnote
	integer seqnum=0
	(($#Q))&& {
		[[ $Q[-1] =~ '^[0-9]+' ]]|| die "IMPOSSIBLE THING #1."
		seqnum=$MATCH
	  }
	integer tries=5
	while ((tries--)); do
		((seqnum++))
		seqnote=$seqnum.note
		ln $TMPFILE $seqnote && break
		octet="$(dd bs=1 count=1 status=none if=/dev/urandom)"
		sleep 0.$(printf '%03d' \'$octet)
	done
	rm $TMPFILE
	((tries))|| die 'Could not create %Bnote%b.'
	new -nz note "$*"
	pbpaste >$seqnum
	ln -s $PWD/$seqnum \
		  ${noterepo}/"$(date -u +'%Y-%m-%dz')"${OLDPWD##*/}'-'$seqnum
	(($#))|| v -m'.' $seqnum
	cd $OLDPWD
}

alias t='noglob t'
function t {
	local now="$(date -u +'%Y-%m-%d %H:%M:%S Z')"
	local H="@ $now" TODO="$*"
	[[ -n $TODO ]]|| vared -M vitextblock -m vtxtblckcmd TODO
	{ printf '%s\n' $H; printf '    %s\n' ${(f)TODO}; } >>TODO
}


# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab
