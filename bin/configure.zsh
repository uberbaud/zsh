#!/usr/bin/env zsh
# @(#)[:5F#yGLCC8*}j2s3W2IC6: 2017/04/10 06:36:24 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab nowrap

. $USR_ZSHLIB/common.zsh || exit 86

twconf=./tw-configure

# Usage {{{1
saftymsg='DELETE ME OR ABORT'
typeset -- this_pgm=${0##*/}
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t"
	'  Run %B$PWD/configure%b leaving out the %B/BUILD%b bit.'
	''
	"    Requires a %S${twconf:gs/%/%%}%s file in the current directory."
	'    That file contains one option per line.  Comments (%S;%s or %S#%s),'
	'    leading, and trailing spaces are removed, and blank lines'
	'    are skipped.'
	'      %GHint: Use an empty file if you don'\''t want options.%g'
	''
	"    If there is no %S${twconf:gs/%/%%}%s one will be created, but you will"
	'    need to edit the file before running this program again.'
	"      %GHint: Remove the %B${saftymsg:gs/%/%%}%b%G line to run sucessfully.%g"
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
while getopts ':h' Option; do
	case $Option in
		h)	-usage $Usage;										;;
		\?)	-die "Invalid option: '-$OPTARG'.";					;;
		\:)	-die "Option '-$OPTARG' requires an argument.";		;;
		*)	bad_programmer "$Option";							;;
	esac
done
# cleanup
unset -f bad_programmer
# remove already processed arguments
shift $(($OPTIND - 1))
# ready to process non '-' prefixed arguments
# /options }}}1

(($#))&& -die 'Unexpected arguments. Expected none.'

BASE="${HOME}/src"
BUILD="${BASE}/BUILD"

[[ $PWD == $BUILD/* ]]|| {
	-die "Expected to be run in a subdirectory of %B${BUILD:gs/%/%%}%b."
  }

src=${BASE}/${PWD#$BUILD/}
[[ -d $src ]]|| -die "Expected a %Sparallel%s directory %B~${src#$HOME}%b."

cmd=$src/configure
[[ -f $cmd ]]|| -die "Can't find %Tconfigure%t in %B~${src#$HOME}%b."


[[ -f $twconf ]]|| {
	-warn	"Can't find required %B${twconf:gs/%/%%}%b so creating one."
	awkpgm=(
		'BEGIN'
			'{'
				'print "# @(""#)[Initial]\n";'
				#           ^^ interrupt the mark so this doesn't get
				#           || automatically expanded when editing.
				"print \"$saftymsg\n\";"
				'max=0;'
			'}'
		'/^[ \t]*$/'			'{ print ""; next; }'
		'/FEATURE|PACKAGE/'		'{ next; }' # skip the fake example options
		'/^[ \t]*--((en|dis)able|with(out)?)-/'
			'{'
				'$2="\t# "$2;'				# comment the description
				'print;'
				'l=length($1);'				# keep track of option-name size
				'if (max<l) { max=l; };'	# so we can make the tab that big
				'next;'
			'}'
		# every other line (we nexted the others)
			'{print "# "$0;}'
		'END'
			'{'
				'max=max+1;'				# space for the tab
				'if (max%2) {max=max+1;};'	# space divisible by 2
				'print "\n# vim: ts="max" ft=commented expandtab nowrap"'
			'}'
	  )
	$cmd --help=short | awk "$awkpgm" > $twconf
	-die 'Quitting' \
		"Remove the %B${saftymsg:gs/%/%%}%b line in %S${twconf:gs/%/%%}%s" \
		'and run this again to do the %Tconfigure%t.'
}

twopts=()

< $twconf while read -r ln; do
	[[ $ln =~ $saftymsg ]]&& -die "You must %Bedit ${twconf:gs/%/%%}%b."
	[[ $ln =~ '[#;]' ]]&&    ln=${ln:0:$((MBEGIN-1))}	# rm comment
	[[ $ln =~ '[ \t]+$' ]]&& ln=${ln:0:$((MBEGIN-1))}	# rm trailing sp
	[[ $ln =~ '^[ \t]+' ]]&& ln=${ln:$MEND}				# rm leading sp
	[[ -z $ln ]]&& continue								# it's blank
	twopts+=( $ln )
done


:h1 with
printf '    %s\n' $twopts

:h1 $cmd
$cmd $twopts

# Copyright © 2017 by Tom Davis <tom@greyshirt.net>.
