#!/bin/bash
#
# Check for diffs between the files in this directory (the Git repo)
# and the actual config files in $HOME.

for i in * ; do [ -f ~/.$i ] && diff $i ~/.$i ; done
