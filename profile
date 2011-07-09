# ~/.profile:
#
#  commands to be sourced by the shell when it is invoked as a login shell.
#
# James Boyden, 2005-12-12, for Ubuntu system "iterator".
# Updated 2011-07-07, for Ubuntu system "elemental".

# To quote from the bash(1) manual:
#
#      When  bash is invoked as an interactive login shell, or as a non-inter‐
#      active shell with the --login option, it first reads and executes  com‐
#      mands  from  the file /etc/profile, if that file exists.  After reading
#      that file, it looks for ~/.bash_profile, ~/.bash_login, and ~/.profile,
#      in  that order, and reads and executes commands from the first one that
#      exists and is readable.  The --noprofile option may be  used  when  the
#      shell is started to inhibit this behavior.
#
# Situations in which bash(1) is invoked as a login shell:
#  + login on a console
#  + login via ssh(1)
#
# Situations in which bash(1) is NOT invoked as a login shell:
#  + in an Xterm
#  + in a nested shell instance

# Source "~/.bashrc" if we're running Bash and "~/.bashrc" exists.
if [ -n "$BASH_VERSION" ]
then
	test -f ~/.bashrc && source ~/.bashrc
fi

#echo Finished .profile
