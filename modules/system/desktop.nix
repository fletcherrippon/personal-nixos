{ pkgs, ... }:
{
  # ── GPU / graphics (virtio-gpu-gl / virgl) ─────────────────────────
  hardware.graphics.enable = true;

  # ── Hyprland (the compositor itself; everything else is in home/) ──
  programs.hyprland = {
    enable = true;
    withUWSM = true; # launch via UWSM so systemd graphical-session + portals set up correctly
  };

  # ── Login screen: greetd + tuigreet (tiny, DIY-friendly) ───────────
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd start-hyprland";
      user = "greeter";
    };
  };

  # ── XDG portals (screen share, native file pickers, etc.) ──────────
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ── Make Electron / Chromium / Firefox use native Wayland ──────────
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Needed by the graphical auth agent we autostart inside Hyprland.
  security.polkit.enable = true;

  # dconf backs the gsettings store that carries the dark-mode preference
  # (org.gnome.desktop.interface color-scheme). Without a full DE, enable it
  # here so the setting persists and the portal can read it.
  programs.dconf.enable = true;
}
