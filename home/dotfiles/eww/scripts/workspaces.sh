#!/usr/bin/env bash
# Emit the gap-filled workspace list on every workspace-related Hyprland event,
# instead of polling. Each item: { id, occupied, active }.
#   - occupied: a real workspace exists at this id
#   - active:   currently focused workspace
# Driven by Hyprland's IPC event socket (.socket2.sock) so it updates the
# instant something changes and is otherwise idle (no CPU between events).

emit() {
  local active
  active=$(hyprctl activeworkspace -j | jq '.id')
  hyprctl workspaces -j | jq -c --argjson a "$active" '
    [.[].id | select(. > 0)] as $ids
    | (($ids | max) // 1) as $m
    | [range(1; $m + 1) as $i
        | { id: $i, occupied: (($ids | index($i)) != null), active: ($i == $a) }]'
}

# initial state, then one emit per relevant event
emit
socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - \
  | while read -r line; do
      case "$line" in
        workspace*|createworkspace*|destroyworkspace*|moveworkspace*|renameworkspace*|focusedmon*|activespecial*)
          emit ;;
      esac
    done
