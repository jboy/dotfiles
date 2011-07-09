# ~/.bash/builtins.bash:
#
#  builtin commands to be sourced by the Bash shell.
#
# James Boyden, 2005-12-12, for Ubuntu system "iterator".
# Updated 2011-07-07, for Ubuntu system "elemental".

#echo ~/.bash/builtins.bash

# Allow at most 711 for directories and 600 for files.
umask 066

# Check the window size after each command and, if necessary, update the
# values of LINES and COLUMNS.
shopt -s checkwinsize

