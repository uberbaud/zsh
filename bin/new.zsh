#!/usr/bin/env zsh
# @(#)[:X93vVX5NB~Yr|@$29V(n: 2017/02/18 20:55:20 tw@csongor.lan]
# vim: ts=4 tw=72 noexpandtab
# TODO: this script calls perl to do the replace, so maybe we should
#		convert it to perl anyway.

emulate -L zsh
. $USR_ZSHLIB/common.zsh|| exit 86

# ======================================================================
#   TEMPLATES DIRECTORY STUFF
# ======================================================================
# use the environment variable if it exists, otherwise use ~/.templates
template_dir="${TEMPLATES_FOLDER:-${HOME}/.templates}"

# check to see if we can access our templates
[[ -d "$template_dir" ]] || -die "%B${template_dir:gs/%/%%}%b is %BNOT%b a directory."
[[ -r "$template_dir" ]] || -die "You can not read %B${template_dir:gs/%/%%}%b."

# ======================================================================
#   PROCESS OPTIONS                                                {{{1
# ======================================================================
typeset -a Usage=(
	'%Tnew%t [%T-d%t] [%T-n%t] [%T-z%t|%T-t%t %Uext%u] %Ufull_name%u %Udesc%u'
	'  %T-d%t  do not use %BRCS%b, and mark it so %Tv%t won'\''t either'
	'  %T-n%t  do not edit (still does an initial RCS checkin)'
	'  %T-t%t  ext will use the template for that extension.  This overrides any'
	  '      actual extension, no description required.'
	'  %T-x%t  include template specific mod'
	'  %T-z%t  Create a temporary file, the contents of which are copied to the'
	'        clipboard after editing. Then the file is deleted.'
	'  %Udesc%u Use this description for RCS log message, and'
	'        IN the file (%BDESCRIPTION%b).'
	'        The description is %Ball%b trailing words.'
	' '
	'%Tnew%t [%T-V%t] [%T-T%t]'
	'  %T-V%t  list available variables and values'
	'  %T-T%t  list available templates'
	' '
	'%Tnew%t [%T-X%t %Utemplate%u]'
	'  %T-X%t  list available mods for template'
	' '
	'%Tnew -h%t'
	'  %T-h%t  print this message.'
)

# do some declaring, but don't overwrite any values we might be passed
typeset -- RUN_DONT_RCS=false
typeset -- DO_EDIT=true
typeset -- DESCRIPTION=''
typeset -- USE_TMPFILE=false
# do some overwriting here
typeset -- extension=''
# plus some other processing variables
typeset -a newModules=()
typeset -i SHOW_COUNT
typeset -- SHOW_VARIABLES=false
typeset -- SHOW_TEMPLATES=false
typeset -- SHOW_MODS_FOR=''


function set-vars { #{{{2

	export FILE_NAME=$1
	export FILE_W_EXT=$file_name
	export BASE_FILE=$file_base
	export TITLE=${TITLE:-$BASE_FILE}
	export DATE=${(%)${:-%D{%Y-%m-%d}}}
	export YEAR=${(%)${:-%D{%Y}}}
	export AUTHOR=${AUTHOR:-${${${(ps.:.)$(getent passwd $USERNAME)}[5]}%%,*}}
	export ORGANIZATION=${ORGANIZATION:-$AUTHOR}
	export COPYRIGHT="Copyright (C) ${YEAR} by ${ORGANIZATION}${EMAIL:+ <${EMAIL}>}."
	export CCOPYRIGHT="${COPYRIGHT/\(C\)/©}"

}; # }}}2
function warnOrDie {	#{{{1
	case $warnOrDie in
		die)  -die $@ 'Use %T-f%t to force an edit.';	;;
		warn) -warn $@;									;;
		*)    -die '%BProgrammer error%b:' 'warnOrDie is %B${warnOrDie:gs/%/%%}%b.'
	esac
}	# }}}1
function list-vars { # {{{2
	# set some vars we would need to figure out if we weren't just 
	# listing them.
	directory='path'
	file_name='SomeFile.Ext'
	extension='Ext'
	file_base='SomeFile'

	# use the same function to set things that we would if we were 
	# really doing it so we get it exact.
	set-vars "$directory/$file_name"

	typeset -a varlist=(
		'%F{4}  Filename Related variables:%f'
		"    «[FILE_NAME]»    := '${FILE_NAME}'"
		"    «[FILE_W_EXT]»   := '${FILE_W_EXT}'"
		"    «[BASE_FILE]»    := '${BASE_FILE}'"
		' ' # empty slots aren't expanded with $varlist
		'%F{4}  Automagical variables:%f'
		"    «[TITLE]»        := '${TITLE}'"
		'                       %F{248}# $TITLE || $BASE_FILE%f'
		"    «[DATE]»         := '${DATE}'"
		"    «[YEAR]»         := '${YEAR}'"
		"    «[AUTHOR]»       := '${AUTHOR}'"
		"    «[ORGANIZATION]» := '${ORGANIZATION}'"
		'                       %F{248}# $ORGANIZATION | $AUTHOR%f'
		"    «[COPYRIGHT]»    := '${COPYRIGHT}'"
		'                       %F{248}# Copyright (C) $YEAR by $ORGANIZATION <$EMAIL>.%f'
		'                       %F{248}# $EMAIL must be exported elsewhere%f'
		"    «[CCOPYRIGHT]»   := '${CCOPYRIGHT}'"
		'                       %F{248}# Copyright © $YEAR by $ORGANIZATION <$EMAIL>.%f'
		"    «:IDENT:»        := '@(""#)[:stemma: $(date -u +'%Y/%m/%d %H:%M:%S') $USERNAME@$HOST]"
		'                       %F{248}# @(''#)[:stemma: %%Y/%%m/%%d %%H:%%M:%%S $USERNAME@$HOST]%f'
		'%F{4}  And if you use %F{2}-m %Urcs initial message%u%F{4}, then%f'
		"    «[DESCRIPTION]»  := '%Urcs initial message%u'"
	  )
	print -Plu 2 $varlist
  }; # }}}2

typeset awk_rlog2description=( #{{{2
	'/^description:/,/^====/'
		'{'
			'if ( ! match($0, /^(description:|=+)$/ ) )'
				'print $0;'
		'}'
  ); #}}}2
function get-template-info { #{{{2
	typeset --  f_name=$1
	if [[ -h $f_name ]]; then
		printf 'alias for \e[35m%s\e[0m' ${$(readlink -f $f_name)#*/_.}
	elif [[ -d $f_name ]]; then
		sed -e '2,$s/^/	/' "$f_name/description.txt"
	else
		/usr/bin/rlog -t $f_name						\
			| /usr/bin/awk "$awk_rlog2description"		\
			| sed -E '2,$s/^/	/'
	fi
}; #}}}2
function list-templates { # {{{2
	print '  Installed Templates'
	typeset -a	templates=( $template_dir/_.*(:t) )
	templates=( ${templates#_.} )
	typeset -i	width=${#${(O)${templates//?/X}}[1]}

	typeset -- tname='' fname='' descr=''
	for tname in $templates; do
		fname=$template_dir/_.$tname
		descr="$( get-template-info $fname )"
		if [[ -d $fname ]]; then
			printf "    \e[34m%-${width}s\e[0m  %s\n" $tname $descr
		else
			printf "    \e[1m%-${width}s\e[0m  %s\n" $tname $descr
		fi
	done | expand -t $((width+6))
	printf '\t\e[34mtemplates with mods\e[0m, \e[1mother templates\e[0m\n'
}; # }}}2
typeset -- warnOrDie='die'
typeset -a vopts=()
while getopts ":dnt:x:z:hVTX:f" Option; do
	case $Option in
		d)	RUN_DONT_RCS=true;							;;
		n)	DO_EDIT=false;								;;
		t)	extension="${OPTARG}";						;;
		x)	newModules+=( "${OPTARG}" );				;;
		z)	USE_TMPFILE=true; extension="${OPTARG}";	;;
		h)	-usage "${Usage[@]}";						;;
		V)	SHOW_VARIABLES=true;						;;
		T)	SHOW_TEMPLATES=true;						;;
		X)	SHOW_MODS_FOR="${OPTARG}";					;;
		f)	warnOrDie='warn'; vopts+=( -f );			;;
		:)	-die "Missing parameter for ${OPTARG}";		;;
		\?)	-die "Unknown option '-$OPTARG'.";			;;
	esac
done
# let's remove all of the already processed bits
shift $(($OPTIND - 1))

function get-mods-list { # {{{2
	typeset -- template=$1
	typeset -- f_mods=$template/mods_list.txt
	if [[ -a $f_mods ]]; then
		typeset -a lines=( ${(f)"$(<$f_mods)"} )
		# remove lines beginning with a semi-colon
		for line in ${(@)lines}; do
			[[ $line == \;* ]] || mods_list+=( $line )
		done
	else
		mods_list=('No mods for this template');
	fi
}; # }}}2
if [[ -n $SHOW_MODS_FOR ]]; then
	typeset template="$template_dir/_.$SHOW_MODS_FOR"
	[[ -a $template	 ]]		\
		|| -die "There is no template %B_.${SHOW_MODS_FOR:gs/%/%%}%b in %B${template_dir:gs/%/%%}%b."
	[[ -d $template ]] || -die 'No mods for this template'
	typeset -a mods_list
	get-mods-list $template

	# these opts are for the show_mods bit only, we exit thereafter
	-notify $mods_list ''

	exit
fi

# LESS OPTIONS
#	-F	--quit-if-one-screen
#	-X	--no-init				# don't send tinfo init
#	-c	--clear-screen			# from bottom, not from top
#	-i	--ignore-case
#	-n	--line-numbers			# turns OFF line numbers
#	-R	--RAW-CONTROL-CHARS
#	-W	--HILITE-UNREAD

{ $SHOW_VARIABLES || $SHOW_TEMPLATES } && {
	$SHOW_VARIABLES && list-vars
	# add a blank line between the two, if there are two
	$SHOW_VARIABLES && $SHOW_TEMPLATES && echo
	$SHOW_TEMPLATES && list-templates
  } 2>&1 | /usr/bin/env LESS='-FXcinRW' less

# exit if we were just showing off
$SHOW_VARIABLES && exit
$SHOW_TEMPLATES && exit

if $USE_TMPFILE; then
	(( $# == 0 )) || -die 'Unexpected arguments. No %Ufilename%u or %Udesc%u needed.'
	DESCRIPTION='Temporary File'
	cmdln_arg=$( mktemp )
	-notify "Using tempfile UB${cmdln_arg:gs/%/%%}%b."
else
	(( $# > 0 )) || -die 'No file given to create nor description.'
	(( $# > 1 )) || -die 'Missing required %Bdescription%b.'

	cmdln_arg=$1; shift
	DESCRIPTION="$*"

	[[ -e $cmdln_arg ]] && -die "%B${cmdln_arg:gs/%/%%}%b already exists."
fi

# }}}1
# ======================================================================
#  FILL IN SOME IMPORTANT VARIABLES                                {{{1
# ======================================================================
directory="${cmdln_arg%/*}"
file_name="${cmdln_arg##*/}"
# set $extension only if we didn't do it with an option
[[ -z "$extension" ]] && extension="${file_name##*.}"
file_base="${file_name%.*}"
[[ $directory == $file_name ]] && directory='.'

template="$template_dir/_.$extension"
[[ -e "$template" ]] || {
	-die "There is no template %B_.${extension:gs/%/%%}%b in %B${template_dir:gs/%/%%}%b."
}
														# }}}1
# ======================================================================
#   CHANGE OUR WORKING DIRECTORY TO THE FILE'S DIRECTORY
# ======================================================================
if [[ $directory != '.' ]]; then
	cd $directory || -die "Could not %Tcd%t to %B${directory:gs/%/%%}%b."
	cmdln_arg=$file_name
fi
:git:on:master	\
	&& warnOrDie 'new: This is the %B%Smaster%s branch%b of a %Bgit%b repo.'

# ======================================================================
#  DO THE TRANFORMATION                                            {{{1
# ======================================================================
function do-common { # {{{2
	typeset -r	file_path="$1"

	# make sure the file was actually created.
	# This could be an issue especially for directory templates
	[[ -a $file_path ]] || -die "Did not create %B${file_path:gs/%/%%}%b."

	chmod u+w $file_path

	set-vars $file_path

	# skip any lines containing the REMark declaration
	typeset -- file=''
	for ln in "${(@f)$(< $file_path )}"; do
		[[ $ln =~ '«REM»' ]] && continue
		file+=${ln}$'\n'
	done

	# replace any RCS identifier with the RCS keyword syntax
	while [[ $file =~ '«RCS:([[:alpha:]]+)»' ]]; do
		file=${file/$MATCH/\$$match\$}
	done

	# replace «[env_var]» with value of environment variable
	typeset -- rxEnv='«\[([[:alnum:]_]+)\]»'
	function check_for_cyclical_matching {
		[[ ${(P)1} =~ $rxEnv ]] || return 0
		-die "%B\$${1:gs/%/%%}%b contains an expansion directive."	\
			"  '${(P)1:gs/%/%%}'"
	}

	while [[ $file =~ $rxEnv ]]; do
		check_for_cyclical_matching $match
		file=${file/$MATCH/${(P)match}}
	done

	# replace new style Identity string
	typeset -- IDENT='«:IDENT:»'
	[[ $file =~ $IDENT ]] && {
		typeset -a now=( $(date -u +'%Y/%m/%d %H:%M:%S') )
		typeset -- stemma=$(uuid85|tr '>' , )
		typeset -- newid='@(''#'')'"[:$stemma: $now $USERNAME@$HOST]"
		file=${file:gs/«:IDENT:»/$newid}
	}

	print -Rn $file > $file_path

}; # }}}2

function handle-directory-template { #{{{2
	typeset -r	template="$1"
	typeset -r	file_path="$2"
	if [[ -a "$template/_.$extension" ]]; then
		cp -p "$template/_.$extension" $file_path
		on_error -die "Could not create %B${file_path:gs/%/%%}%b" "from %B${template:gs/%/%%}%b."
	fi
	typeset -a scripts=( $template/before*(N) )
	# the following scripts (before*, add_mods.[sh|pl], after*) will 
	# exit THIS script on fail, as they are included using . and don't 
	# run in a subshell
	for script in $scripts; do
		. $script $template $file_path
	done
	if (( $#newModules )); then
		if [[ -a $template/add-mods.sh ]]; then
			. $template/add-mods.sh $template $file_path $newModules
			on-error -die '%Badd-mods.sh%b died, and so we do too.'
		elif [[ -a $template/add-mods.pl ]]; then
			$template/add-mods.pl $template $file_path $newModules
			on-error -die '%Badd-mods.pl%b died, and so we do too.'
		else
			-die "This template does not handle adding modules." "  ${^newModules[@]}"
		fi
	elif [[ -n $REQUIRE_MODS ]]; then
		get-mods-list $template mods_list
		-die 'This template requires mods (%T-x %Umod%u%t)' "  ${^mods_list[@]}"
	fi
	scripts=( $template/after*(N) );
	for script in $scripts; do
		. $script $template $file_path
	done
	do-common $file_path
}; #}}}2
function handle-file-template { #{{{2
	typeset -r	template=$1
	typeset -r	file_path=$2
	cp -p $template $file_path
	on_error -die "Could not create %B${file_path:gs/%/%%}%b" "from %B${template:gs/%/%%}%b."
	do-common $file_path
}; # }}}2

if [[ -d "$template" ]]; then
	handle-directory-template $template $cmdln_arg
else
	handle-file-template $template $cmdln_arg
fi

																# }}}1

# ======================================================================
#   DO THE EDIT AND RCS STUFF                                     {{{1
# ======================================================================
$RUN_DONT_RCS && [[ -w RCS/ ]] && $USRBIN/dont-rcs $file_name

if $DO_EDIT; then
	vopts+=( -m $DESCRIPTION -- )
	v $vopts $file_name;
elif [[ -w RCS/ ]]; then
	if ! $RUN_DONT_RCS; then
		typeset -a ci_opts=(
			-i	# initial check-in
			-u	# unlock file (keep a copy checked out) after versioning
			-q	# quietly (some messages)
		)
		[[ -n $DESCRIPTION ]] && ci_opts+=( "-t-'$DESCRIPTION'" )
		# do the check-in
		echo /usr/bin/ci $ci_opts \"$file_name\"
		/usr/bin/ci $ci_opts -- $file_name
	fi
elif ! $RUN_DONT_RCS; then
	# we didn't say DONT_RCS (-d) but there's no RCS/ writable directory
	typeset -a warning_msg=()
	if [[ -d RCS/ ]]; then
		warning_msg=(
			"%BRCS/%B is %Bnot%b writable by $(id -un),"
			'so %BNO%b versioning of this file.'
		  )
	else
		warning_msg=( 'No %BRCS/%b so %BNO%b versioning of this file.' )
	fi
	-warn $warning_msg
fi
																# }}}1
if $USE_TMPFILE; then
	$SYSLOCAL/bin/xclip -selection clipboard -in < $file_name
	rm -f $file_name
fi

# vim: nowrap
