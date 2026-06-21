#!/usr/bin/env bash
# Event-driven workspace data for eww, off Hyprland's IPC socket (.socket2.sock)
# instead of polling -- updates the instant something changes, idle otherwise.
#
#   workspaces.sh list    -> gap-filled [{id, occupied}], re-emit on create/destroy
#   workspaces.sh active  -> active workspace id, re-emit on focus change
#
# active is kept SEPARATE from the list on purpose: if it lived inside each item,
# every focus change would alter the list and make eww recreate the buttons,
# which kills the active-pill width transition. Keeping the list stable across
# focus changes lets the CSS transition animate.

sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

list() {
  hyprctl workspaces -j | jq -c '
    [.[].id | select(. > 0)] as $ids
    | (($ids | max) // 1) as $m
    | [range(1; $m + 1) as $i | { id: $i, occupied: (($ids | index($i)) != null) }]'
}
active() { hyprctl activeworkspace -j | jq -c '.id'; }

case "$1" in
  list)
    list
    socat -u UNIX-CONNECT:"$sock" - | while read -r line; do
      case "$line" in
        createworkspace*|destroyworkspace*|moveworkspace*|renameworkspace*) list ;;
      esac
    done
    ;;
  active)
    active
    socat -u UNIX-CONNECT:"$sock" - | while read -r line; do
      case "$line" in
        workspace*|focusedmon*) active ;;
      esac
    done
    ;;
esac
