# ~/.pythonrc.py
#
#  per-user Python configuration commands, executed at interpreter startup.
#
# The interpreter must be informed of the existence of this file by setting
# the PYTHONSTARTUP environment variable:
#   export PYTHONSTARTUP=~/.pythonrc.py
#
# See http://docs.python.org/using/cmdline.html#envvar-PYTHONSTARTUP

# Only load these config settings if the interpreter is in interactive mode;
# or else the results can confuse the Cinnamon tools written in Python.
# (This method of determining whether the interpreter is in interactive mode
# is from http://stackoverflow.com/a/2356445 )
#     If no interface option is given, -i is implied, sys.argv[0] is an
#     empty string ("") and the current directory will be added to the
#     start of sys.path.
#      -- http://docs.python.org/2/using/cmdline.html

from __future__ import print_function
import sys as _sys

if _sys.argv[0] == "":
    print('Loading configuration file "~/.pythonrc.py".', file=_sys.stderr)

    # Enable shell autocomplete for syntax completion.
    # See http://docs.python.org/tutorial/interactive.html
    # and the complete code in
    # http://www.razorvine.net/blog/user/irmen/article/2004-11-22/17
    import readline as _readline
    import rlcompleter

    # This is a module in my PYTHONPATH.
    import custom_readline_bindings as _custom_readline_bindings

    for _binding in _custom_readline_bindings.get_bindings().items():
        _readline.parse_and_bind("%s: %s" % _binding)

    print('Enabled key mappings:', file=_sys.stderr)
    for _binding in _custom_readline_bindings.get_readable_bindings():
        print('  % 8s  ->  %s' % _binding, file=_sys.stderr)
