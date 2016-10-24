#!/usr/bin/env zsh
# $Id: pass-gen.zsh,v 1.3 2016/09/18 06:40:08 tw Exp $
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. "$USR_ZSHLIB/common.zsh"

typeset -i default_min=13
typeset -i default_max=19
typeset -- default_alphabet='SNCL'
typeset -i default_count=7

# Usage {{{1
typeset -- this_pgm=${0##*/}
typeset -a synopsis=( #{{{2
	"%T${this_pgm:gs/%/%%}%t"
	'%Tpass%t'
	'[%Upassword options%u]'
	'[%Uoutput options%u]'
	'[%Uretention options%u]'
  ) #}}}2
typeset -a pwd_opts=( #{{{2
	'[%T-n%t %Umin len%u]'
	'[%T-x%t %Umax len%u]'
	'[%T-a%t %Ualphabet%u]'
	'[%T-c%t %Uhow many%u]'
  ) #}}}2
typeset -a pwd_defaults=( #{{{2
	"%Umin len%u=%B${default_min:gs/%/%%}%b,"
	"%Umax len%u=%B${default_max:gs/%/%%}%b,"
	"%Ualphabet%u=%B${default_alphabet:gs/%/%%}%b,"
	"%Uhow many%u=%B${default_count:gs/%/%%}%b"
  ) #}}}2
typeset -a retention=( #{{{2
	'[%T-e%t %Uemail addr%u]'
	'[%T-u%t %Uuser name%u]'
	'[%T-O%t %Uid type%u:%Uid%u]'
	'[%Udomain%u]'
  ) #}}}2
# %T/%t => terminal (green fg)
# %S/%s => special  (magenta fg)
typeset -a Usage=(
	"$synopsis"
	'  Generates a %Bsecure%b password.'
	'%BPassword Options%b'
	"    $pwd_opts"
	'  The %Balphabet%b argument can be:'
	'      %US%u, %Us%u, %UP%u, or %Up%u for symbols/punctuation'
	'      %UN%u, %Un%u, %UD%u, or %Ud%u for numerals/digits'
	'      %UC%u, %Uc%u, %UU%u, or %Uu%u for capital/uppercase letters'
	'      %UL%u, or %Ul%u for lower case letters'
	'    An upper case flag means at least one character from the class'
	'    WILL occur in every password. A lower case flag means it MIGHT.'
	'  %Bdefaults%b:'
	"    $pwd_defaults"
	'%BOutput Options%b'
	'    %T-q%t  Quiet, list all generated to %Ustdout%u, nothing else.'
	'    %T-v%t  Verbose, give some additional info.'
	'%BRetention Options%b'
	"    ${(@)^retention}"
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
### process args declarations
typeset -i count=$default_count
typeset -- alphabet_is_set=false
typeset -- info_is_set=false
# start with impossible values so we can check later
typeset -i max_len=-1
typeset -i min_len=-1
typeset -i require_length=0
typeset -- allowed_chars=''
typeset -a required_chars=()
typeset -- verbose=false
typeset -- quiet=false

### process args helper function
function set_alphabet { #{{{2
	(( $# == 1 ))|| -die '%Uset alphabet%u expects exactly one (1) arg.'
	typeset -- req_alphabet=$1
	[[ -n $req_alphabet ]]|| -die '%Ualphabet%u cannot be %Bempty%b.'

	typeset -- allow_UC=false
	typeset -- allow_LC=false
	typeset -- allow_SYM=false
	typeset -- allow_DIG=false

	typeset -- require_UC=false
	typeset -- require_LC=false
	typeset -- require_SYM=false
	typeset -- require_DIG=false

	typeset -a ALPHA=()
	typeset -- c='-'

	for (( i=0; i<$#req_alphabet; i++ )); do
		c=${req_alphabet:$i:1}
		case $c in
			S|P) require_SYM=true;			;&
			s|p) allow_SYM=true;			;;
			N|D) require_DIG=true;			;&
			n|d) allow_DIG=true;			;;
			C|U) require_UC=true;			;&
			c|u) allow_UC=true;				;;
			L)   require_LC=true;			;&
			l)   allow_LC=true;				;;
			*)   -die "Unknown alphabet specifier %U${c:gs/%/%%}%u."
		esac
	done

	$allow_SYM	&& allowed_chars+='[:punct:]'
	$allow_DIG	&& allowed_chars+='[:digit:]'
	$allow_UC	&& allowed_chars+='[:upper:]'
	$allow_LC	&& allowed_chars+='[:lower:]'

	$require_SYM  && { required_chars+=('punct'); ((require_length++)); }
	$require_DIG  && { required_chars+=('digit'); ((require_length++)); }
	$require_UC   && { required_chars+=('upper'); ((require_length++)); }
	$require_LC   && { required_chars+=('lower'); ((require_length++)); }

	alphabet_is_set=true

} #}}}2
function posint { #{{{2
	(( $# == 2 ))|| -die '%Tpos_integer%t expected two (2) args.'
	typeset -- varname=$1
	typeset -- errmsg="%U${varname:gs/%/%%}%u MUST be a positive decimal integer."
	typeset -i posint=0

	[[ $2 == <-> ]]|| -die $errmsg
	posint=$2
	(( $posint >= 1 ))|| -die $errmsg

	typeset -gi $varname=$posint
  } #}}}2
function add_id { #{{{2
	(( $# == 2 ))|| -die "%BBad Arguments%b: expected %B2%b, found %B$#%b."
	typeset -l id_type=$1
	typeset -- id=$2
	ids+=( "$id_type: $id" )
	info_is_set=true
} #}}}2
function add_custom_id { #{{{2
	(( $# == 1 ))|| -die "%BBad Arguments%b: expected %B1%b, found %B$#%b."
	typeset -l key=${1%%:*}
	typeset -- val=${1:$#key+1}
	[[ -n $val ]]|| -die "Bad %Ucustom id%u format for %B${1:gs/%/%%}%b."
	add_id $key $val
} # }}}2
while getopts ':a:c:n:x:e:u:O:vqh' Option; do
	case $Option in
		a)	set_alphabet $OPTARG;								;;
		c)	posint count $OPTARG;								;;
		n)	posint min_len $OPTARG;								;;
		x)	posint max_len $OPTARG;								;;
		e)	add_id 'eml' $OPTARG;								;;
		u)	add_id 'usr' $OPTARG;								;;
		O)	add_custom_id $OPTARG;								;;
		v)	verbose=true;										;;
		q)	quiet=true;											;;
		h)	-usage $Usage;										;;
		\?)	-die "Invalid option: '-$OPTARG'.";					;;
		\:)	-die "Option '-$OPTARG' requires an argument.";		;;
		*)	bad_programmer "$Option";							;;
	esac
done
# cleanup
unset -f bad_programmer
shift $(($OPTIND - 1))
# ready to process non '-' prefixed arguments

$quiet && $verbose && -die 'Cannot do %Bquiet%b AND %Bverbose%b.'

### after cleanup, set defaults
$alphabet_is_set || set_alphabet $default_alphabet

# max MUST come before min so that -1 won't be kept for min
if (( $max_len == -1 )); then
	max_len=$min_len
	(( $max_len < $default_max ))&& max_len=$default_max
fi
if (( $min_len == -1 )); then
	min_len=$max_len
	(( $min_len > $default_min ))&& min_len=$default_min
fi

(( $max_len >= $min_len ))|| -die '%Uminum%u %Bmust%b be less than %Bmaximum%b.'
(( $max_len >= $require_length ))|| -die 'There are more %Brequired%b characters than %Umax_length%u allows.'

(( $min_len > $require_length ))|| min_len=$require_length

# /options }}}1

(( $# <= 1 ))|| -die 'Unexpected arguments.'
typeset -l domain=''
(($#))&& domain=$1

if $info_is_set; then
	[[ -n $domain ]]|| -die '%Udomain%u is required to %Brecord%b %Uinfo%u.'
elif [[ -n $domain ]]; then
	-die '%Uemail addr%u, %Uuser name%u, or some other %Uid%u must be supplied' \
		 'when saving to %Udomain%u.pwd'
fi

typeset -r pwd_file="$HOME/.local/secrets/${domain}.pwd"
[[ -a $pwd_file ]]&& -die "Password file for %B${domain:gs/%/%%}%b already exists."

### verbose
if $verbose; then # ${{{1
	typeset -- password_s='password'
	(( $count > 1 )) && password_s+='s'
	typeset -- min_max_phrase="between %B$min_len%b and %B$max_len%b"
	(( $min_len == $max_len )) && min_max_phrase="exactly %B$min_len%b"
	typeset -a msg=(
		"Generating %B$count%b $password_s,"
		"$min_max_phrase ascii characters long."
		"%BAllowed%b characters match '$allowed_chars'."
	  )
	if (( $#required_chars == 0 )); then
		msg+=( 'There are %Bno%b required classes.' )
	else
		msg+=( "%BRequired%b classes are $required_chars." )
	fi
	-notify $msg
fi; #}}}1

### choose password setup
typeset -i wiggleroom=$(( max_len - min_len + 1 ))
function get_a_len_between_min_and_max { #{{{1
	echo $(( min_len + (RANDOM % wiggleroom) ))
} #}}}1

typeset -a passwords=()
typeset -i generated=0
while :; do
	typeset -i len=$( get_a_len_between_min_and_max )
	typeset -- pass="$(
		tr -cd $allowed_chars < /dev/urandom \
		| dd bs=$len count=1 status=none
	  )"
	# check against every required and redo while if any are missing
	for class in $required_chars; do
		[[ $pass =~ [[:$class:]] ]] || continue 2
	done
	# passed test, so keep it and count it toward requested count
	passwords+=( $pass )
	(( ++generated < $count ))|| break
done

if $quiet; then
	print $passwords
else
	### choose a password from those generated
	typeset -- password="$( $USRBIN/menu $passwords )"

	[[ -n $password ]]|| -die "No information saved"

	echo -n $password | $SYSLOCAL/bin/xclip -selection clipboard -in
	-notify 'Your new %Bpassword%b has been copied to the %Bclipboard%b.'
	add_id 'pwd' $password
	if [[ -n $domain ]]; then
		-notify "It is also saved in %B${pwd_file:gs/%/%%}%b."
		for ln in $ids; do echo $ln; done | tee -a $pwd_file
	else
		for ln in $ids; do echo $ln; done
	fi
fi

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
