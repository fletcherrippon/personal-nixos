# Host-aware terminal launcher. In the VM, Ghostty must use software GL (virgl
# can't give GTK4 a modern GL context); on real hardware it runs native. The bar
# and keybinds all launch `term`, so the shared dotfiles never hardcode either.
{ pkgs, isVM, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "term" (
      if isVM
      then ''exec env LIBGL_ALWAYS_SOFTWARE=1 ghostty "$@"''
      else ''exec ghostty "$@"''
    ))
  ];
}
