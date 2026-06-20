{
  config,
  pkgs,
  isVM,
  ...
}:
let
  # Where this repo lives on the machine. Clone it to exactly this path so the
  # "out of store" symlinks below resolve to editable files (edit + reload,
  # no rebuild needed). Same path on the VM and the Framework.
  dotfiles = "${config.home.homeDirectory}/personal-nixos/home/dotfiles";
in
{
  imports = [
    ./apps/shell.nix
    ./apps/theme.nix
    ./apps/term.nix # host-aware `term` command (software GL only on the VM)
  ];

  home.username = "fletcher";
  home.homeDirectory = "/home/fletcher";
  home.stateVersion = "26.05";

  # System cursor — themes GTK, X/XWayland, and Hyprland (via XCURSOR_* env).
  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # ── The desktop you assemble yourself ──────────────────────────────
  home.packages = with pkgs; [
    # Wayland desktop pieces
    waybar # status bar (currently unused; eww bar is active)
    fuzzel # app launcher (Super+R)
    mako # notification popups
    awww # wallpaper daemon (swww renamed; CPU-based, VM-safe)
    lutgen # recolours a wallpaper to match the palette
    hyprlock # lock screen
    hypridle # auto-lock / screen-off when idle
    hyprpolkitagent # graphical password prompts (polkit)
    libnotify # `notify-send` for testing notifications
    grim
    slurp # screenshots: grim = capture, slurp = pick a region
    wl-clipboard # wl-copy / wl-paste
    cliphist # clipboard history (Super+.)
    playerctl # media keys
    brightnessctl # backlight (real on the Framework; no-op in the VM)
    networkmanagerapplet # nm-applet tray icon
    pavucontrol # audio mixer GUI

    # Apps
    ghostty # your terminal (launched via the `term` wrapper)
    zed-editor # your editor
    firefox # browser
    nautilus # file manager (Super+E)

    eww # widget toolkit for the custom bar
  ];

  # ── Live-editable, version-controlled rice configs ─────────────────
  # mkOutOfStoreSymlink points ~/.config/<app> at the REAL files in this repo,
  # so you can edit them and reload to see changes instantly.
  xdg.configFile = {
    "hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr";
    "waybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/waybar";
    "fuzzel".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/fuzzel";
    "mako".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/mako";
    "eww".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/eww";
    "theme".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/theme";

    # Per-host Hyprland fragment (sourced by hyprland.conf). It lives OUTSIDE
    # the symlinked hypr dir so Nix can generate it differently per host.
    "hypr-host/host.conf".text =
      if isVM then
        ''
          # ── VM-only Hyprland tweaks ──────────────────────────────
          # virgl has no usable hardware cursor.
          cursor {
              no_hardware_cursors = true
          }
          # Framebuffer is forced to 1920x1200 by the kernel `video=` param
          # (see modules/system/vm.nix) because UTM's SPICE auto-resize is
          # broken. scale 1.5 -> 1280x800 logical (1920/1.5 is a whole number,
          # which Hyprland requires for fractional scales). Keep UTM
          # "Resize display to window size automatically" OFF.
          monitor = Virtual-1, 1920x1200, auto, 1.5
        ''
      else
        ''
          # ── Native hardware ──────────────────────────────────────
          monitor = , preferred, auto, 1
        '';
  };

  # (theme regeneration on rebuild lives in apps/theme.nix, beside the binary)
}
