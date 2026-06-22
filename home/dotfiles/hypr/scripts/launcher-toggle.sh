#!/usr/bin/env bash
# Toggle anyrun (Spotlight/Raycast style): close it if open, else open it.
# Esc still closes it via anyrun's own keybind -- this just adds open/close on
# the same shortcut (Super+Space).
#
# Match the cmdline 'anyrun': the Nix-wrapped process has comm `.anyrun-wrapped`
# but argv[0] is plain `anyrun`. -f also catches `anyrun-provider`, so the whole
# launcher tears down. This script's path has no "anyrun" in it, so pgrep/pkill
# never match the toggle itself. Killing (not re-launching) avoids anyrun's
# single-instance D-Bus panic when a second copy starts.
if pgrep -f anyrun >/dev/null; then
  pkill -f anyrun
else
  anyrun
fi
