# ~/.bash/misccmds.bash:
#
#  miscellaneous commands to be sourced by the Bash shell.
#
# James Boyden, 2005-12-12, for Ubuntu system "iterator".
# Updated 2011-07-07, for Ubuntu system "elemental".

#echo ~/.bash/misccmds.bash

# Make 'less' more friendly for non-text input files (see lesspipe(1)).
test -x /usr/bin/lesspipe && eval "$(SHELL=/bin/sh lesspipe)"

# Read and evaluate (and export) the configuration file for colour 'ls'.
if [ -e /usr/bin/dircolors -a -f $HOME/.dir_colors ]
then
	eval `/usr/bin/dircolors -b ~/.dir_colors`
fi

# Enable programmable shell-completion.
if [ -f /etc/bash_completion ] && ! shopt -oq posix
then
	source /etc/bash_completion
fi

