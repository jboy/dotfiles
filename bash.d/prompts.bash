# ~/.bash/prompts.bash:
#
#  command-prompt definitions to be sourced by the Bash shell.
#
# James Boyden, 2005-12-12, for Ubuntu system "iterator".
# Updated 2011-07-07, for Ubuntu system "elemental".

#echo ~/.bash/prompts.bash

# Set primary shell prompt.
#
# It's rather elaborate, but it's something that has evolved to meet my needs
# over more than a decade, across several different systems (Solaris, Red Hat,
# Debian, SuSE, Slackware, more Debian, Fedora, and finally Ubuntu since 2005).
#
# For readability, I've split it over multiple lines; each line is ended with a
# single backslash '\' to tell the shell to continue reading on the next line.
#
# This prompt consists of:
#  1. reminders of some useful new Bash / GNU Readline keyboard shortcuts
#     that I'm trying to learn/remember (beyond the familiar C-l, C-d, C-c,
#     C-h, C-w, C-u, C-p, C-n, C-a, C-e and C-z).
#     These are coloured blue, so they are readable but not distracting.
#  2. username@hostname/terminal
#     The username and hostname are bold, but not otherwise coloured
#     (so they will be equally-readable on black or white backgrounds).
#  3. the current shell nesting level, in parens.
#     (If you exit a shell at level 1, you will exit the system/Xterm.)
#  4. The full current working directory.
#     This is coloured red, so it is readable but not distracting on both
#     black and white backgrounds.
#  5. The date and time at which this prompt was presented, in square brackets.
#  6. The current command-history number, preceded by an exclamation point.
#     You can execute a previous command in the command history, by typing
#     an exclamation point followed by the command's command-history number.
#  7. A hash '#' if we're root; a dollar-sign '$' otherwise.
#
# Every line of the prompt begins with a hash '#', the shell comment character,
# to minimise any crazy behaviour if I accidentally copy-n-paste the prompt.
#
# The ANSI escape-sequences are:
#  a. \033[34m = blue text colour
#  b. \033[0m  = reset text
#  c. \033[1m  = bold text
#  d. \033[31m = red text colour
#
# Apparently each escape-sequence should be surrounded by "\[" and "\]", to
# delimit a sequence of non-printing characters.  According to the wisdom of
# the Internet, this enables Bash to calculate word-wrapping correctly.
#
# For more info:
# http://www.ibm.com/developerworks/linux/library/l-tip-prompt/
# https://wiki.archlinux.org/index.php/Color_Bash_Prompt

PS1='\n# \[\033[34m\]C-r = reverse-search-history; C-x C-e = edit-and-execute-command\[\033[0m\]\
\n# \[\033[34m\]fc [-l] = fix command: edit-and-execute prev command / List last 10\[\033[0m\]\
\n# \[\033[34m\]Rebound:\
 C-y = historY in reverse; C-t = "pushd "; C-k = kill-word\[\033[0m\]\
\n# \[\033[34m\]        \
 C-b = character-search-backward; C-f = character-search\[\033[0m\]\
\n#\
\n# \[\033[1m\]\u\[\033[0m\]@\[\033[1m\]\h\[\033[0m\]/\l '"(${SHLVL})"' \
 \[\033[31m\]\w\[\033[0m\]\
\n#\
\n# [ \d, \t ]\n# !\! \$ '

# If this is an Xterm, set the title to "user@host:dir".
# Update: Actually, set it to "host: working-directory (date)".
case "$TERM" in
xterm*|rxvt*)
	#PS1="\[\e]0;\u@\h: \w (\d)\a\]${PS1}"
	PS1="\[\e]0;\h: \w (\d)\a\]${PS1}"
	;;
*)
	;;
esac

PS2='# > '
