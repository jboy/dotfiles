# ~/.bash/aliases.bash:
#
#  aliases to be sourced by the Bash shell.
#
# James Boyden, 2005-12-12, for Ubuntu system "iterator".
# Updated 2011-07-07, for Ubuntu system "elemental".

#echo ~/.bash/aliases.bash

# Tell Vim to read my damn Vimrc.
alias vi='vim -u $HOME/.vimrc'

# Interactively double-check before nuking any files.
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Colour output.
if [ -x /usr/bin/dircolors ]
then
	alias ls='ls --color=auto'
	alias ll='ls -l --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# An 'alert' alias for long-running commands.
# Use it like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

