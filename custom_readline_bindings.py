# ~/lib-py/custom_readline_bindings.py
#
#  Custom Readline bindings, to be imported by the Python startup file.
#
# Example usage:
#
#   import sys
#   import readline
#   import custom_readline_bindings
#
#   for binding in custom_readline_bindings.get_bindings():
#     readline.parse_and_bind("%s: %s" % binding)
#
#   print >> sys.stderr, 'Enabled key mappings:'
#   for binding in custom_readline_bindings.get_readable_bindings():
#     print >> sys.stderr, '  % 8s  ->  %s' % binding


import types


__BINDINGS = {
  # Each dictionary key is a key-sequence.
  # The corresponding dictionary value is the target binding.
  # If the value is a pair, the zeroth element is the target binding;
  # the first element is a human-readable alias for the binding.

  # Use Tab to trigger shell-like autocomplete.
  'tab':            ('complete', 'tab-complete'),

  # Use shift-Tab to insert a literal tab.
  #
  # "\e[Z" == "^[[Z" == shift-tab.
  # To find out more exciting combinations like this, run "cat -v"
  # and then press all your favourite non-ASCII keys.
  r'"\e[Z"':        'tab-insert',

  # Increase indentation of line using C-j (like C-t in Vim).
  #
  # Literally, this macro is: set-mark; beginning-of-line; insert-tab;
  # exchange-point-and-mark; right-arrow (to compensate for the extra
  # tab character inserted; Readline seems to track the set-mark position
  # as a character-position offset).
  r'"\C-x\C-m"':    ('set-mark', 'set-mark (then C-xC-x to exchange-point-and-mark)'),
  r'C-j':           ('"\C-x\C-m\C-a\e[Z\C-x\C-x\e[C"', 'increase-indent'),

  # Decrease indentation of line (the inverse of C-j).
  #
  # Literally, this macro is: left-arrow (since exchange-point-and-mark seems
  # to become confused if the line is shorter than the set-mark position,
  # which will occur if you were at the end of the line when you set the mark,
  # and then you delete a character in the line); set-mark; beginning-of-line;
  # right-arrow; backspace; exchange-point-and-mark.
  #
  # "\et" is the cryptic "keyseq" method of specifying Meta-t (Alt-t).
  # It seems to be the only way to bind Meta/Alt on a modern Linux system.
  # http://www.devheads.net/linux/fedora/user/readline-binding-still-frustrated-after-4-yrs-trying.htm
  #
  # Note that this binding also makes use of the binding of "\er" (Alt-r)
  # to backward-delete-char that is performed later.
  # Previously "\b" (the backspace character) was used, but for some reason
  # it stopped working after the rebinding of Alt-r was added...  :\
  #r'"\et"':         '"\e[D\C-x\C-m\C-a\e[C\b\C-x\C-x"',
  #r'C-k':           '"\e[D\C-x\C-m\C-a\e[C\b\C-x\C-x"',
  r'C-k':           ('"\e[D\C-x\C-m\C-a\e[C\er\C-x\C-x"', 'decrease-indent'),

  # Bind the End key to menu-complete to cycle through possible completions,
  # and the Home key to the reverse.
  #r'"\eOF"':        'menu-complete',
  #r'"\eOH"':        'menu-complete-backward',
  r'C-t':           ('menu-complete', 'tab-complete-cycle-forward'),
  # Next, I wanted to use C-s for the reverse of C-t, but it seems
  # that either the Python interpreter or Readline just eats it...  :\
  #r'C-s':           'menu-complete-backward',
  r'"\et"':         ('menu-complete-backward', 'tab-complete-cycle-reverse'),

  # Bind Meta-c (Alt-c) to insert a comment at the beginning of the line.
  r'"\ec"':         'insert-comment',

  # Swap the move-by-char and move-by-word commands.
  r'C-f':           'forward-word',
  r'C-b':           'backward-word',
  r'"\ef"':         'forward-char',
  r'"\eb"':         'backward-char',

  # Swap the delete-char and delete-word commands.
  r'C-r':           ('backward-kill-word', 'rubout-word (backward)'),
  r'C-d':           ('kill-word', 'delete-word (forward)'),
  r'"\er"':         ('backward-delete-char', 'rubout-char (backward)'),
  r'"\ed"':         ('delete-char', 'delete-char (forward)'),

  # Remap C-r and C-s character-search commands to C-a and C-e
  r'"\ea"':         ('character-search-backward', 'char-search-forward (towards beginning of line)'),
  r'"\ee"':         ('character-search', 'char-search-backward (towards end of line)'),

  r'C-h':           'previous-history',
  r'C-n':           'next-history',  # Already the default
  r'"\eh"':         'reverse-search-history',
  r'"\en"':         'forward-search-history',
}


def get_bindings():
  def __get_binding(b):
    if type(b) == types.TupleType:
      return b[0]
    else:
      return b

  return [(k, __get_binding(b)) for k, b in __BINDINGS.iteritems()]


def get_readable_bindings():
  def __get_readable_keyseq(k):
    k = k.replace('"', '')

    if k == 'tab':
      return 'Tab'
    if k == '\\e[Z':
      return 'S-Tab'

    k = k.replace('\\C', 'C')
    k = k.replace('\\e', 'M-')

    return k

  def __get_readable_binding(b):
    if type(b) == types.TupleType:
      return b[1]
    else:
      return b

  bindings = [(__get_readable_keyseq(k), __get_readable_binding(b))
      for k, b in __BINDINGS.iteritems()]

  return sorted(bindings)

