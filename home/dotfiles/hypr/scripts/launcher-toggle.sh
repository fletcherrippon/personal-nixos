#!/usr/bin/env bash
# Toggle anyrun (Spotlight/Raycast style): close it if open, else open it.
# Esc still closes it via anyrun's own keybind -- this just adds open/close on
# the same shortcut (Super+Space).
#
# Match on 'bin/anyrun' rather than the process name: Nix wraps the binary, so
# the running process is `.anyrun-wrapped`, but its argv[0] is `.../bin/anyrun`.
# Matching the path also keeps this script from matching its own invocation.
if pgrep -f 'bin/anyrun' >/dev/null; then
  pkill -f 'bin/anyrun'
else
  anyrun
fi
