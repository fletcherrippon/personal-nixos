{ config, pkgs, lib, isVM, ... }:
let
  # Where this repo lives on the machine. Clone it to exactly this path so the
  # "out of store" symlinks below resolve to editable files (edit + reload,
  # no rebuild needed). Same path on the VM and the Framework.
  dotfiles = "${config.home.homeDirectory}/personal-nixos/home/dotfiles";
in {
  imports = [
    ./apps/shell.nix
    ./apps/theme.nix
    ./apps/term.nix     # host-aware `term` command (software GL only on the VM)
  ];

  home.username = "fletcher";
  home.homeDirectory = "/home/fletcher";
  home.stateVersion = "26.05";

  # ── The desktop you assemble yourself ──────────────────────────────
  home.packages = with pkgs; [
    # Wayland desktop pieces
    waybar               # status bar (currently unused; eww bar is active)
    fuzzel               # app launcher (Super+R)
    mako                 # notification popups
    swww                 # wallpaper daemon (image wallpapers; CPU-based, VM-safe)
    lutgen               # recolours a wallpaper to match the palette
    hyprlock             # lock screen
    hypridle             # auto-lock / screen-off when idle
    hyprpolkitagent      # graphical password prompts (polkit)
    libnotify            # `notify-send` for testing notifications
    grim slurp           # screenshots: grim = capture, slurp = pick a region
    wl-clipboard         # wl-copy / wl-paste
    cliphist             # clipboard history (Super+.)
    playerctl            # media keys
    brightnessctl        # backlight (real on the Framework; no-op in the VM)
    networkmanagerapplet # nm-applet tray icon
    pavucontrol          # audio mixer GUI

    # Apps
    ghostty              # your terminal (launched via the `term` wrapper)
    zed-editor           # your editor
    firefox              # browser
    nautilus             # file manager (Super+E)

    eww                  # widget toolkit for the custom bar
  ];

  # ── Live-editable, version-controlled rice configs ─────────────────
  # mkOutOfStoreSymlink points ~/.config/<app> at the REAL files in this repo,
  # so you can edit them and reload to see changes instantly.
  xdg.configFile = {
    "hypr".source   = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr";
    "waybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/waybar";
    "fuzzel".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/fuzzel";
    "mako".source   = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/mako";
    "eww".source    = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/eww";
    "theme".source  = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/theme";

    # Per-host Hyprland fragment (sourced by hyprland.conf). It lives OUTSIDE
    # the symlinked hypr dir so Nix can generate it differently per host.
    "hypr-host/host.conf".text =
      if isVM then ''
        # ── VM-only Hyprland tweaks ──────────────────────────────
        # virgl has no usable hardware cursor; pin the resolution.
        cursor {
            no_hardware_cursors = true
        }
        monitor = , 1800x1169@60, auto, 1
      '' else ''
        # ── Native hardware ──────────────────────────────────────
        monitor = , preferred, auto, 1
      '';
  };

  # Regenerate the (gitignored) theme fragments on every rebuild, so they always
  # exist and match theme.conf. Fresh clones and new hosts just work, and `theme`
  # still does live updates between rebuilds.
  home.activation.generateTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    bash "$HOME/.config/theme/apply.sh" || true
  '';
}
