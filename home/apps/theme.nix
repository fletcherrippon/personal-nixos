{ pkgs, lib, ... }:
let
  theme = pkgs.rustPlatform.buildRustPackage {
    pname = "theme";
    version = "0.1.0";
    src = ../../pkgs/theme;
    cargoLock.lockFile = ../../pkgs/theme/Cargo.lock;
  };
in {
  # `theme` — a generic, template-driven generator (pkgs/theme/src/main.rs).
  # It reads ~/.config/theme/theme.conf and renders every template in
  # ~/.config/theme/templates/ to the @out path each declares, then recolours
  # the wallpaper and reloads. Add a variable or a whole new tool by editing
  # theme.conf and the templates — no Rust changes needed.
  home.packages = [ theme ];

  # Regenerate the (gitignored) fragments on every rebuild, from the templates.
  # The reload/wallpaper steps no-op during activation (no running session).
  home.activation.generateTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${theme}/bin/theme || true
  '';
}
