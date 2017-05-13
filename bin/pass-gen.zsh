#!/usr/bin/env zsh
# @(#)[:M7dUbt+qzxTO!nD}9M<g: 2017/05/13 01:25:43 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

. $USR_ZSHLIB/common.zsh|| exit 86

typeset -i defaultMin=13
typeset -i defaultMax=19
typeset -- defaultAlphabet='SNCL'
typeset -i defaultCount=7

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
	"%Umin len%u=%B${defaultMin:gs/%/%%}%b,"
	"%Umax len%u=%B${defaultMax:gs/%/%%}%b,"
	"%Ualphabet%u=%B${defaultAlphabet:gs/%/%%}%b,"
	"%Uhow many%u=%B${defaultCount:gs/%/%%}%b"
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
function bad-programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
### process args declarations
typeset -i count=$defaultCount
typeset -- alphabetIsSet=false
typeset -- infoIsSet=false
# start with impossible values so we can check later
typeset -i maxLen=-1
typeset -i minLen=-1
typeset -i requireLength=0
typeset -- allowedChars=''
typeset -a requiredChars=()
typeset -- verbose=false
typeset -- quiet=false

### process args helper function
function set-alphabet { #{{{2
	(( $# == 1 ))|| -die '%Uset alphabet%u expects exactly one (1) arg.'
	typeset -- reqAlphabet=$1
	[[ -n $reqAlphabet ]]|| -die '%Ualphabet%u cannot be %Bempty%b.'

	typeset -- allowUC=false
	typeset -- allowLC=false
	typeset -- allowSYM=false
	typeset -- allowDIG=false

	typeset -- requireUC=false
	typeset -- requireLC=false
	typeset -- requireSYM=false
	typeset -- requireDIG=false

	typeset -a ALPHA=()
	typeset -- c='-'

	for (( i=0; i<$#reqAlphabet; i++ )); do
		c=${reqAlphabet:$i:1}
		case $c in
			S|P) requireSYM=true;			;&
			s|p) allowSYM=true;			;;
			N|D) requireDIG=true;			;&
			n|d) allowDIG=true;			;;
			C|U) requireUC=true;			;&
			c|u) allowUC=true;				;;
			L)   requireLC=true;			;&
			l)   allowLC=true;				;;
			*)   -die "Unknown alphabet specifier %U${c:gs/%/%%}%u."
		esac
	done

	$allowSYM	&& allowedChars+='[:punct:]'
	$allowDIG	&& allowedChars+='[:digit:]'
	$allowUC	&& allowedChars+='[:upper:]'
	$allowLC	&& allowedChars+='[:lower:]'

	$requireSYM  && { requiredChars+=('punct'); ((requireLength++)); }
	$requireDIG  && { requiredChars+=('digit'); ((requireLength++)); }
	$requireUC   && { requiredChars+=('upper'); ((requireLength++)); }
	$requireLC   && { requiredChars+=('lower'); ((requireLength++)); }

	alphabetIsSet=true

} #}}}2
function posint { #{{{2
	(( $# == 2 ))|| -die '%Tpos_integer%t expected two (2) args.'
	typeset -- varname=$1
	typeset -- errmsg="%U${varname:gs/%/%%}%u MUST be a positive decimal integer."
	typeset -i posint=0

	[[ $2 == <-> ]]|| -die $errmsg
	posint=$2
	((1<=$posint))|| -die $errmsg

	typeset -gi $varname=$posint
  } #}}}2
function add-id { #{{{2
	(( $# == 2 ))|| -die "%BBad Arguments%b: expected %B2%b, found %B$#%b."
	typeset -l idType=$1
	typeset -- id=$2
	ids+=( "$idType: $id" )
	infoIsSet=true
} #}}}2
function add-custom-id { #{{{2
	(( $# == 1 ))|| -die "%BBad Arguments%b: expected %B1%b, found %B$#%b."
	typeset -l key=${1%%:*}
	typeset -- val=${1:$#key+1}
	[[ -n $val ]]|| -die "Bad %Ucustom id%u format for %B${1:gs/%/%%}%b."
	add-id $key $val
} # }}}2
while getopts ':a:c:n:x:e:u:O:vqh' Option; do
	case $Option in
		a)	set-alphabet $OPTARG;								;;
		c)	posint count $OPTARG;								;;
		n)	posint minLen $OPTARG;								;;
		x)	posint maxLen $OPTARG;								;;
		e)	add-id 'eml' $OPTARG;								;;
		u)	add-id 'usr' $OPTARG;								;;
		O)	add-custom-id $OPTARG;								;;
		v)	verbose=true;										;;
		q)	quiet=true;											;;
		h)	-usage $Usage;										;;
		\?)	-die "Invalid option: '-$OPTARG'.";					;;
		\:)	-die "Option '-$OPTARG' requires an argument.";		;;
		*)	bad-programmer "$Option";							;;
	esac
done
# cleanup
unset -f bad-programmer
shift $(($OPTIND - 1))
# ready to process non '-' prefixed arguments

$quiet && $verbose && -die 'Cannot do %Bquiet%b AND %Bverbose%b.'

### after cleanup, set defaults
$alphabetIsSet || set-alphabet $defaultAlphabet

# max MUST come before min so that -1 won't be kept for min
if ((maxLen == -1)); then
	maxLen=$minLen
	((maxLen<defaultMax))&& maxLen=$defaultMax
fi
if ((minLen == -1)); then
	minLen=$maxLen
	((defaultMin<minLen))&& minLen=$defaultMin
fi

((minLen <= maxLen))|| -die '%Uminum%u %Bmust%b be less than %Bmaximum%b.'
((requireLength  <= maxLen))|| -die 'There are more %Brequired%b characters than %UmaxLength%u allows.'

((requireLength<minLen))|| minLen=$requireLength

# /options }}}1

(( $# <= 1 ))|| -die 'Unexpected arguments.'
typeset -l domain=''
(($#))&& domain=$1

if $infoIsSet; then
	[[ -n $domain ]]|| -die '%Udomain%u is required to %Brecord%b %Uinfo%u.'
elif [[ -n $domain ]]; then
	-die '%Uemail addr%u, %Uuser name%u, or some other %Uid%u must be supplied' \
		 'when saving to %Udomain%u.pwd'
fi

typeset -r pwdFile="$HOME/.local/secrets/${domain}.pwd"
[[ -a $pwdFile ]]&& -die "Password file for %B${domain:gs/%/%%}%b already exists."

### verbose
if $verbose; then # ${{{1
	typeset -- password_s='password'
	((1<count)) && password_s+='s'
	typeset -- min_max_phrase="between %B$minLen%b and %B$maxLen%b"
	(( $minLen == $maxLen )) && min_max_phrase="exactly %B$minLen%b"
	typeset -a msg=(
		"Generating %B$count%b $password_s,"
		"$min_max_phrase ascii characters long."
		"%BAllowed%b characters match '$allowedChars'."
	  )
	if (( $#requiredChars == 0 )); then
		msg+=( 'There are %Bno%b required classes.' )
	else
		msg+=( "%BRequired%b classes are $requiredChars." )
	fi
	-notify $msg
fi; #}}}1

### choose password setup
typeset -i wiggleroom=$(( maxLen - minLen + 1 ))
function get-a-len-between-min-and-max {
	echo $(( minLen + (RANDOM % wiggleroom) ))
} #}}}1

typeset -a passwords=()
typeset -i generated=0
while :; do
	typeset -i len=$( get-a-len-between-min-and-max )
	typeset -- pass="$(
		tr -cd $allowedChars < /dev/urandom |
		dd bs=$len count=1 status=none
	  )"
	# check against every required and redo while if any are missing
	for class in $requiredChars; do
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
	typeset -- password="$( $LOCALBIN/umenu $passwords )"

	[[ -n $password ]]|| -die "No information saved"

	echo -n $password | $SYSLOCAL/bin/xclip -selection clipboard -in
	-notify 'Your new %Bpassword%b has been copied to the %Bclipboard%b.'
	add-id 'pwd' $password
	if [[ -n $domain ]]; then
		-notify "It is also saved in %B${pwd_file:gs/%/%%}%b."
		for ln in $ids; do echo $ln; done | tee -a $pwd_file
	else
		for ln in $ids; do echo $ln; done
	fi
fi

# Copyright © 2016 by Tom Davis <tom@greyshirt.net>.
