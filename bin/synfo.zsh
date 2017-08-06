#!/usr/bin/env zsh
# @(#)[:y}iP-=lc9LvggFV|y{#S: 2017/08/05 14:25:23 tw@csongor.lan]

emulate -L zsh
. $USR_ZSHLIB/common.zsh || exit 86

# Usage {{{1
typeset -- this_pgm=${0##*/}
typeset -a Usage=(
	"%T${this_pgm:gs/%/%%}%t [-cCgiIsW] %Ufile type%u"
	'  Show information about a %Bvim syntax%b file.'
	'    %T-c%t  List %Bcontained%b groups.'
	'    %T-C%t  List minimal %Buncontained%b groups (in TOP).'
	'        Groups contained in a cluster will not be listed.'
	'    %T-g%t  List all %Bgroup names%b.'
	'    %T-i%t  List groups with %Bhighlight%b declarations.'
	'    %T-I%t  List groups without %Bhighlight%b declarations.'
	'    %T-s%t  Show general %Bstats%b.'
	'    %T-W%t  Do %Bnot%b show warnings (the default is to show them).'
	"%T${this_pgm:gs/%/%%} -h%t"
	'  Show this help message.'
); # }}}1
# process -options {{{1
function bad_programmer {	# {{{2
	-die '%BProgrammer error%b:' "  No %Tgetopts%t action defined for %T-$1%t."
  };	# }}}2
typeset -- showContained=false
typeset -- showUncontained=false
typeset -- showGroupNames=false
typeset -- showHighlighted=false
typeset -- showUnhighlighted=false
typeset -- showStats=false
typeset -- showWarnings=true
while getopts ':cCiIsWh' Option; do
	case $Option in
		c)	showContained=true;									;;
		C)	showUncontained=true;								;;
		g)	showGroupNames=true;								;;
		i)	showHighlighted=true;								;;
		I)	showUnhighlighted=true;								;;
		s)	showStats=true;										;;
		W)	showWarnings=false;									;;
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

(($#))||	-die 'Missing required %Usyntax file%u'
(($#==1))||	-die 'Too many arguments. Expected one (1).'

typeset -- fname=$1
[[ $fname == *.* ]]|| fname=$fname.vim
[[ -e $fname ]]|| {
	[[ -e ${MYVIM}/syntax/$fname ]]|| -die 'Could not find %Usyntax file%u.'
	fname=${MYVIM}/syntax/$fname
}
[[ -f $fname ]]|| -die "%B${fname:gs/%/%%}%b is not a file."
[[ -s $fname ]]|| -die "%B${fname:gs/%/%%}%b is empty."
[[ -r $fname ]]|| -die "%B${fname:gs/%/%%}%b is not readable."
typeset slurp="$(<$fname)"

typeset -- compact=''
printf '  compacting… '
while [[ $slurp =~ '\n\s*\\' ]]; do
	printf '.'
	compact+="${slurp:0:$((MBEGIN-1))}"
	slurp="${slurp:$MEND}"
done
printf ' …finished.\n'
slurp="${compact}${slurp}"
unset compact

typeset -- hicmd='hi(g(h(l(i(g(ht?)?)?)?)?)?)?'
typeset -a hi_awkpgm=( # {{{1
	'{ sub( /^[ \t]+/, "" ); }'	# remove leading spaces for field splitting
	'{ sub( /('$hicmd'[ \t]+link|HiLink)[ \t]+/, "link " ); }'
	'/^link/'					'{ print; }'
	'/^'$hicmd'[ \t]/'			'{ print "hi ", $2; }'
  ) # }}}1
typeset -a syn_awkpgm=( # {{{1
	'{ sub( /^[ \t]+/, "" ); }'	# remove leading spaces for field splitting
	'/^syn(t(ax?)?)?[ \t]+(region|match|cluster)/'
		'{ sub( /^syn(t(ax?)?)?[ \t]+/, "" ); print; }'
  ) # }}}1
syntax="$( awk "$syn_awkpgm" <<<"$slurp" )"
hiall="$( awk "$hi_awkpgm" <<<"$slurp" )"

function genFind { # {{{1
		egrep -o "$1" <<<"${(P)2}"			|
		awk -F'[ \t=]+' '{print $2;}'		|
		sort								|
		uniq
} # }}}1
function synFind { genFind $1 syntax; }
function hiFind { awk '{print $2}' <<<$hiall | sort | uniq; }
typeset -a vimHiGroups=( # {{{1
  Comment        Identifier     Keyword        Type           Delimiter
  Constant       Function       Exception      StorageClass   SpecialComment
  String         Statement      PreProc        Structure      Debug
  Character      Conditional    Include        Typedef        Underlined
  Number         Repeat         Define         Special        Ignore
  Boolean        Label          Macro          SpecialChar    Error
  Float          Operator       PreCondit      Tag            Todo
) # }}}
function hilinkFind { # {{{1
	awk '/^link/ {print $3}' <<<$hiall | sort | uniq |
		egrep -v '^('${(j:|:)vimHiGroups}')$'
} # }}}1
function incFind { # {{{1
	egrep -o '(contain(s|edin)|nextgroup|add|remove)=[^[:space:]]*' \
		<<<$syntax 				|
		awk -F= '{print $2;}'	|
		tr , '\n'				|
		sort					|
		uniq					|
		egrep -v '^(TOP|CONTAINED|ALL(BUT)?|@(No)?Spell|NONE)$'
} # }}}1
function clusterMath { # {{{1
	awkpgm="$(cat)" <<-\---
		BEGIN { FS="[ \t=]"; }
		function explode (str,a,i,s,x) {
			split(str,a,",")
			str=""
			for (i in a) {
				if (a[i] ~ "^@") {
					s=a[i];
					sub(/^@/,"",s);
					str=str","explode( c[s] );
		  		}
				else {
					str=str","a[i];
				}
	  		}
		
			return str;
		}
		/^cluster / && $3=="contains" { c[$2]=$4 }
		/^cluster / && $3=="add" { c[$2]=c[$2]","$4; }
		/^cluster / && $3=="remove" {
			split(c[$2],e,/,/);
			for (i in e) { E[e[i]]=1; }
			split($4,r,/,/);
			for (i in r) delete E[r[i]];
			j=""; for (i in E) j=j","i;
			c[$2]=j
			}
		END {
			for (i in c) {
				s=explode( c[i] );
				gsub(/,+/,",",s);
				sub(/^,/,"",s);
				print i"\n"s
	  		}
		}
	---
	awk "$awkpgm" <<<$syntax
} # }}}1

typeset SP=$'[ \t]' NS=$'[^ \t]'
typeset rxValid='(region|match)'$SP'+'$NS'+'
typeset -aU clusters=(    $(synFind '^cluster'$SP'.*')                 )
typeset -aU createds=(    $(synFind '(region|match)'$SP'+'$NS'+')      )
typeset -aU matchgrps=(   $(synFind 'matchgroup='$NS'+')               )
typeset -aU matchonly=(   ${matchgrps:|createds}                       )
			createds+=(   "@${(@)^clusters}"                           )
typeset -aU valids=(      $createds $matchgrps                         )
typeset -aU containeds=(  $(synFind $rxValid'.*'$SP'contained[[:>:]]')
						  $matchonly
						)
typeset -aU hi_linked=(   $(hilinkFind)                                )
typeset -aU hi_decl=(     $(hiFind)                                    )
typeset -aU highlighted=( $hi_decl $hi_linked                          )
typeset -aU referenced=(  $(incFind) $highlighted                      )
typeset -aU invalids=(    ${referenced:|valids}                        )
typeset -A  cgjunction=(  ${(f)"$(clusterMath)"}                       )
typeset -aU clstrdgrps=();
			for v (${(v)cgjunction}) { clstrdgrps+=( ${(s:,:)v} ); }
typeset -aU uncontained=( ${valids:|containeds}                        )
typeset -aU minimaltops=( ${uncontained:|clstrdgrps}                   )

$showStats && { # {{{1
	printf '\e[34m<<<<<<<<<<<<<<<< stats >>>>>>>>>>>>>>>>>\e[39m\n'
    (){
	    printf '    valid groups: %5s\n' $#valids
	    printf '    clusters:     %5s\n' $#clusters
	    printf '    invalid:      %5s\n' $#invalids
	    printf '    contained:    %5s\n' $#containeds
	    printf '    highlighted:  %5s\n' $#highlighted
	    printf '    referenced:   %5s\n' $#referenced
  } | column } # }}}1
$showContained && { # {{{1
	printf '\e[34m<<<<<<<<<<<<<< contained >>>>>>>>>>>>>>>\e[39m\n'
	printf '  %s\n' $containeds | column
} #}}}1
$showUncontained && { # {{{1
	printf '\e[34m<<<<<<<<<<<<<<<<< TOP >>>>>>>>>>>>>>>>>>\e[39m\n'
	printf '  %s\n' $minimaltops | column
} #}}}1
$showGroupNames && { # {{{1
	printf '\e[34m<<<<<<<<<<<<< group names >>>>>>>>>>>>>>\e[39m\n'
	for i in $valids; do
		C=''
		(($containeds[(I)$i]))&& C='*'
		printf '  %s%s\n' $i $C
	done | column
} # }}}1
$showHighlighted && { # {{{1
	printf '\e[34m<<<<<<<<<<<<< highlighted >>>>>>>>>>>>>>\e[39m\n'
	printf '  %s\n' $highlighted | column
} #}}}1
$showUnhighlighted && { # {{{1
	printf '\e[34m<<<<<<<<<<<< unhighlighted >>>>>>>>>>>>>\e[39m\n'
	printf '  %s\n' ${valids:|highlighted} | column
} #}}}1
$showWarnings && { # {{{1
	typeset -a itemAndCluster=( ${clusters:*valids} )
	(($#itemAndCluster+$#invalids))&&
	  printf '\e[38;5;172m<<<<<<<<<<<<<<< WARNINGS >>>>>>>>>>>>>>>\e[39m\n'

	(($#itemAndCluster))&& {
		-warn 'The following names are used for both Clusters and Groups'
		printf '  %s\n' $itemAndCluster | column
  	}

	(($#invalids))&& {
		-warn 'Group names %Breferenced%b but not %Bcreated%b.'
		printf '      %s\n' $invalids | column
	}
} # }}}1

