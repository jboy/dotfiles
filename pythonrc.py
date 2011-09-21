# ~/.pythonrc.py
#
#  per-user Python configuration commands, executed at interpreter startup.
#
# The interpreter must be informed of the existence of this file by setting
# the PYTHONSTARTUP environment variable:
#   export PYTHONSTARTUP=~/.pythonrc.py
#
# See http://docs.python.org/using/cmdline.html#envvar-PYTHONSTARTUP

import sys
print >> sys.stderr, 'Loading configuration file "~/.pythonrc.py".'

# Enable shell autocomplete for syntax completion.
# See http://docs.python.org/tutorial/interactive.html
# and the complete code in
# http://www.razorvine.net/blog/user/irmen/article/2004-11-22/17
import readline
import rlcompleter

# This is a module in my PYTHONPATH.
import custom_readline_bindings

for binding in custom_readline_bindings.get_bindings().iteritems():
  readline.parse_and_bind("%s: %s" % binding)

print >> sys.stderr, 'Enabled key mappings:'
for binding in custom_readline_bindings.get_readable_bindings():
  print >> sys.stderr, '  % 8s  ->  %s' % binding

