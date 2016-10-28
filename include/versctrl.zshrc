# @(#)[versctrl.zshrc 2016/04/24 05:29:38 tw@csongor.lan]
# vim: filetype=zsh tabstop=4 textwidth=72 noexpandtab

unset -m 'BZR*' 'CVS*' 'DARCS_*' 'GIT_*' 'HG*'

# ─────────────────────────────────────────────── Bazaar (bzr) ──── {{{1
#BZRPATH=
#BZR_EMAIL=
#BZR_EDITOR=
#BZR_PLUGIN_PATH=
BZR_HOME="$XDG_CONFIG_HOME/bzr"
# }}}1
# ─────────────────────────── Concurrent Versions System (cvs) ──── {{{1
#CVSROOT=
#CVSREAD=
#CVSEDITOR=
#CVSREADONLYFS=
#CVS_IGNORE_REMOTE_BOOT=
#CVS_RSH=
#CVS_SERVER=
#CVSWRAPPERS=
# }}}1
# ────────────────────────────────────────────── Darcs (darcs) ──── {{{1
#DARCS_EDITOR=
#DARCS_PAGER=
#DARCS_TMPDIR=
#DARCS_KEEP_TMPDIR=
#DARCS_EMAIL=
#DARCS_SSH=
#DARCS_SCP=
#DARCS_SFTP=
#DARCS_PROXYUSERPWD=
# }}}1
# ────────────────────────────────────────────────── Git (git) ──── {{{1
# repositories
#GIT_INDEX_FILE=
#GIT_INDEX_VERSION=
#GIT_OBJECT_DIRECTORY=
#GIT_ALTERNATE_OBJECT_DIRECTORIES=
#GIT_DIR=
#GIT_WORK_TREE=
#GIT_NAMESPACE=
#GIT_CEILING_DIRECTORIES=
#GIT_DISCOVERY_ACROSS_FILESYSTEM=
# commits
#GIT_AUTHOR_NAME=
#GIT_AUTHOR_EMAIL=
#GIT_AUTHOR_DATE=
#GIT_COMMITTER_NAME=
#GIT_COMMITTER_EMAIL=
#diffs
#GIT_DIFF_OPTS=
#GIT_EXTERNAL_DIFF=
#GIT_DIFF_PATH_COUNTER=
#GIT_DIFF_PATH_TOTAL=
#other
#GIT_MERGE_VERBOSITY=
#GIT_PAGER=
#GIT_EDITOR=
#GIT_SSH=
#GIT_SSH_COMMAND=
#GIT_ASKPASS=
#GIT_TERMINAL_PROMPT=
#GIT_CONFIG_NOSYSTEM=
#GIT_FLUSH=
#GIT_TRACE_PACK_ACCESS=
#GIT_TRACE_PACKET=
#GIT_TRACE_PERFORMANCE=
#GIT_TRACE_SETUP=
#GIT_TRACE_SHALLOW=
#GIT_LITERAL_PATHSPECS=
#GIT_GLOB_PATHSPECS=
#GIT_NOGLOB_PATHSPECS=
#GIT_ICASE_PATHSPECS=
#GIT_REFLOG_ACTION=
# }}}1
# ───────────────────────────────────────────── Mercurial (hg) ──── {{{1
#HG=
#HGEDITOR=
#HGENCODING=
#HGENCODINGMODE=
#HGMERGE=
HGRCPATH="$XDG_CONFIG_HOME/hg"
#HGPLAIN=
#HGPLAINEXCEPT=
#HGUSER=
# }}}1
# ─────────────────────────────────────────── Subversion (svn) ──── {{{1
# }}}1

typeset -x -m 'BZR*' 'CVS*' 'DARCS_*' 'GIT_*' 'HG*'

# Copyright (C) 2016 by Tom Davis <tom@greyshirt.net>.
