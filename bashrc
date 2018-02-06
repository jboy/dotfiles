# ~/.bashrc:
#
#  commands to be sourced by the Bash shell when it is invoked as an
#  interactive non-login shell.
#
# James Boyden, 2005-12-12, for Ubuntu system "iterator".
# Updated 2006-08-17, for Ubuntu 6.06 system "deadstar", so that the exports
# are sourced if they have not yet been read.
# Updated 2011-07-07, for Ubuntu system "elemental".

# To quote from the bash(1) manual:
#
#      When an interactive shell that is not a login shell  is  started,  bash
#      reads  and  executes  commands  from /etc/bash.bashrc and ~/.bashrc, if
#      these files exist.  This may be inhibited by using the  --norc  option.
#      The  --rcfile  file option will force bash to read and execute commands
#      from file instead of /etc/bash.bashrc and ~/.bashrc.
#
# Situations in which bash(1) is invoked as a login shell:
#  + login on a console
#  + login via ssh(1)
#
# Situations in which bash(1) is NOT invoked as a login shell:
#  + in an Xterm
#  + in a nested shell instance

# Note: The next command was in the original "~/.bashrc" file.  I was under
# the impression (after reading the bash(1) manual -- see the excerpt above)
# that "~/.bashrc" is only ever invoked for interactive shells... but just in
# case I'm wrong, I'll leave it in.
#
# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

# Source aliases, builtin shell-commands, non-exporting shell-code and prompts.
#
# Aliases persist only within the current shell process, and hence need to be
# re-set each time a new shell process is spawned.  Builtins persist only
# within the current shell process (I think...).
#
# Note: We're also sourcing miscellaneous commands (such as 'dircolors') here
# because the GDM/Xsession/GNOMERC mechanism doesn't appear to handle the
# export properly.
for dir in ~/.bash.d
do
	for f in aliases builtins misccmds prompts exports
	do
		test -e ${dir}/${f}.bash && source ${dir}/${f}.bash
		test -e ${dir}/${f}.bash.private && source ${dir}/${f}.bash.private
	done
done

# We only want to ignore one EOF if we are in the outermost level of shell
# (regardless of whether we're in an Xterm or a login shell).
if [ "$SHLVL" = 1 ]
then
	export ignoreeof=1
else
	export ignoreeof=0
fi

# If we're in X, silence stupid beeps
#if [ "x$DISPLAY" != "x" ]
#then
#	xset b 500 100 30
#fi

#echo Finished .bashrc

# The next line updates PATH for the Google Cloud SDK.
if [ -f /usr/local/Google_Cloud_SDK/google-cloud-sdk/path.bash.inc ]; then
  source '/usr/local/Google_Cloud_SDK/google-cloud-sdk/path.bash.inc'
fi

# The next line enables shell command completion for gcloud.
if [ -f /usr/local/Google_Cloud_SDK/google-cloud-sdk/completion.bash.inc ]; then
  source '/usr/local/Google_Cloud_SDK/google-cloud-sdk/completion.bash.inc'
fi
