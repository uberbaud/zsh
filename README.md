% README
% Tom Davis
% 2016-10-23

ZSHELL Configuration and Program Files for uberbaud
====================================================

This is my personal ZSH configuration and is based on workflows which 
I may still be using or which I may have abandoned years ago.

Many of these files are based on *bash* files from when that was my 
primary shell.

This set of files is designed to be consistent between various systems 
I use including Arch Linux, OpenBSD, and macOS. I try to move the 
_local_ bits to a single file which is only pulled in on the system 
whose name is the file name (less extension)

Install
--------

Note: I use **xdg** directories and try to keep dot files out of my 
home directory and everything herein is designed around that concept.  
If you haven't previously set up your own **xdg** directories and 
corresponding variables, you will probably want, at least,
  * XDG_CONFIG_HOME -> ~/.config
  * XDG_DATA_HOME   -> ~/.local

Clone this repository to `$XDG_CONFIG_HOME/zsh`.

Copy [repo]`/system/zshenv` to wherever `zsh` expects to find it on 
your system. For instance, `zsh` on OpenBSD looks at `/etc/zshenv` 
whereas on Arch Linux it's `/etc/zsh/zshenv`. This is the only file 
that `zsh` will always source and so should contain some basic 
settings like where you want to put `.zshrc` if not in your home 
directory.

If you don't already have **xdg** directories set up, copy 
[repo]`/system/user-dirs.dirs` to `$XDG_CONFIG_HOME` so it will be 
sourced by `/etc/zshenv` at the beginning of every `zsh` session.

Make soft links from `$ZDOTDIR/bin` to `~/bin` for any executable 
script you want to use regularly. I leave off the exponent.

So for example:
  `ln -s $ZDOTDIR/bin/v.zsh ~/bin/v`


Usage
------

Basically, you're on your own if you want to use any of this.

The ZSHELL `help` command is by default set up to call `man` (for 
manual, type `man 1 man` for more information), which to me doesn't 
make a bit of sense.  If I wanted `man` I would. Coming from a `bash` 
background, I was used to `help` providing a quick lookup of bash 
commands. So I've repiped `help` to do that here.

Additionally, I've begun creating help for my own autoloaded functions 
and those are included in the "$ZDOTDIR/help" directory.

You can get help on scripts in the `$ZDOTDIR/bin` directory by calling 
them with the `-h` flag.

Contributing
-------------

Please see [CONTRIBUTING](CONTRIBUTING.md) for details.

Copyright
----------

Copyright (C) 2016 by Tom Davis <tom@greyshirt.net>.
