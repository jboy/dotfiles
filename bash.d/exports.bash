# ~/.bash/exports.bash:
#
#  exporting shell-code to be sourced by the Bash shell.
#
# James Boyden, 2005-12-12, for Ubuntu system "iterator".
# (Modified 2006-08-17, for Ubuntu 6.06 system "deadstar", to set the shell
# variable HAVE_READ_EXPORTS at the end of this file.)
# Updated 2011-07-07, for Ubuntu system "elemental".

# If we've already read this, don't read it again.
[ -n "${HAVE_READ_EXPORTS}" ] && return

#echo ~/.bash/exports.bash

# Paths to search for executables (in addition to default paths).
if [ -d "${HOME}/bin" ]
then
	PATH="${HOME}/bin:${PATH}"
fi
if [ -d "${HOME}/scr-py" ]
then
	PATH="${HOME}/scr-py:${PATH}"
fi
if [ -d "${HOME}/scr-sh" ]
then
	PATH="${HOME}/scr-sh:${PATH}"
fi
export PATH

# Path to search for python modules (in addition to default python-paths).
if [ -d "${HOME}/lib-py" ]
then
	export PYTHONPATH="${HOME}/lib-py"
fi

# Default editor.
export EDITOR=/usr/bin/vim

# Per-user Python configuration.
export PYTHONSTARTUP=~/.pythonrc.py

# For thesis.
export TEXINPUTS=".:${HOME}/Study/MIT/2011/Schwa_Lab_Git_Repos/tex//:"
export DISTILBASE="${HOME}/dev/distil/code/"

# For WordNet 2.0 (which I don't want to install in a standard location).
export WNHOME=/usr/local/stow/WordNet-2.0

# Default option settings for MPage.  (Worked out by trial-and-error.)
# Note that one sheet margin point is 0.35mm
# ( http://www.cups.org/doc-1.1/sum.html#4_4_4 ).
export MPAGE='-l -2 -m18l45b18r18t -r -X -L55 -P'

# Don't put duplicate command-lines in the history.
HISTCONTROL=ignoredups

# Don't remember these commands in the history (note any flags or arguments
# cause the command to be recognised as a different command).
# Separate with colons.
export HISTIGNORE="ls:ll:history | tac | less:"

# Append to the history file rather than overwriting it.
# (Technically yes this is a built-in, but it fits with these other exports.)
shopt -s histappend

# Set the maximum number of commands in the history.
HISTSIZE=1000
HISTFILESIZE=5000

export HAVE_READ_EXPORTS=1
