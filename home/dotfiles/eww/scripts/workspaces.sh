#!/usr/bin/env bash
# Event-driven workspace data for eww, off Hyprland's IPC socket (.socket2.sock).
#
#   workspaces.sh range  -> [{id}] for 1..max. The list to iterate. Changes ONLY
#                           when max changes (re-emit on create/destroy/move).
#   workspaces.sh state  -> {active, occupied} where occupied is a space-padded
#                           list of occupied ids like " 1 3 " (re-emit on focus
#                           and create/destroy/move).
#
# range and state are deliberately SEPARATE: focusing or occupying a workspace
# must not change the iterated `range` list, or eww rebuilds the buttons and the
# active-pill width transition never plays. (Hyprland creates a gap workspace on
# focus, which is exactly the case that used to break the animation.)

sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

range() {
  hyprctl workspaces -j | jq -c '(([.[].id|select(.>0)]|max)//1) as $m | [range(1;$m+1)|{id:.}]'
}
state() {
  local active occ
  active=$(hyprctl activeworkspace -j | jq '.id')
  occ=$(hyprctl workspaces -j | jq -r '[.[].id|select(.>0)]|map(tostring)|join(" ")')
  printf '{"active":%s,"occupied":" %s "}\n' "$active" "$occ"
}

case "$1" in
  range)
    range
    socat -u UNIX-CONNECT:"$sock" - | while read -r line; do
      case "$line" in
        createworkspace*|destroyworkspace*|moveworkspace*) range ;;
      esac
    done
    ;;
  state)
    state
    socat -u UNIX-CONNECT:"$sock" - | while read -r line; do
      case "$line" in
        workspace*|focusedmon*|createworkspace*|destroyworkspace*|moveworkspace*) state ;;
      esac
    done
    ;;
esac
