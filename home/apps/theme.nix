{ pkgs, ... }:
{
  # The `theme` command. It just runs the live-editable generator script at
  # ~/.config/theme/apply.sh, which rebuilds every tool's theme fragment from
  # ~/.config/theme/theme.conf and reloads everything. Editing apply.sh or
  # theme.conf needs NO rebuild — only adding/removing the command does.
  home.packages = [
    (pkgs.writeShellScriptBin "theme" ''
      exec bash "$HOME/.config/theme/apply.sh" "$@"
    '')
  ];
}
