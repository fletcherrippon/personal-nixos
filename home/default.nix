{ config, pkgs, ... }:
let
  # Where this repo lives INSIDE the VM. Clone it to exactly this path so the
  # "out of store" symlinks below resolve to editable files (edit + reload,
  # no rebuild needed). If you put the repo elsewhere, change this one line.
  dotfiles = "${config.home.homeDirectory}/personal-nixos/home/dotfiles";
in {
  imports = [ ./apps/shell.nix ./apps/theme.nix ];

  home.username = "fletcher";
  home.homeDirectory = "/home/fletcher";
  home.stateVersion = "26.05";

  # ── The desktop you assemble yourself ──────────────────────────────
  home.packages = with pkgs; [
    # Wayland desktop pieces
    waybar               # status bar (top of screen)
    fuzzel               # app launcher (Super+R)
    mako                 # notification popups
    swaybg               # wallpaper (solid colour by default)
    hyprlock             # lock screen
    hypridle             # auto-lock / screen-off when idle
    hyprpolkitagent      # graphical password prompts (polkit)
    libnotify            # `notify-send` for testing notifications
    grim slurp           # screenshots: grim = capture, slurp = pick a region
    wl-clipboard         # wl-copy / wl-paste
    cliphist             # clipboard history (Super+.)
    playerctl            # media keys
    brightnessctl        # (no-op in a VM, handy on real hardware)
    networkmanagerapplet # nm-applet tray icon
    pavucontrol          # audio mixer GUI

    # Apps
    ghostty              # your terminal
    zed-editor           # your editor
    firefox              # ARM-native browser (Zen is x86_64-only on Linux)
    nautilus             # file manager (Super+E)

    # Widget toolkit for custom bars/widgets. Current nixpkgs eww ships with
    # Wayland support built in, so no override is needed.
    eww
  ];

  # ── Live-editable, version-controlled rice configs ─────────────────
  # mkOutOfStoreSymlink points ~/.config/<app> at the REAL files in this repo,
  # so you can edit them and run `hyprctl reload` to see changes instantly,
  # while still keeping everything tracked in git.
  xdg.configFile = {
    "hypr".source   = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr";
    "waybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/waybar";
    "fuzzel".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/fuzzel";
    "mako".source   = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/mako";
    "eww".source    = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/eww";
    "theme".source  = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/theme";
  };
}
