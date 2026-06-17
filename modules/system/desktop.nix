{ pkgs, ... }:
{
  # ── GPU / graphics (virtio-gpu-gl / virgl) ─────────────────────────
  hardware.graphics.enable = true;

  # ── Hyprland (the compositor itself; everything else is in home/) ──
  programs.hyprland.enable = true;

  # ── Login screen: greetd + tuigreet (tiny, DIY-friendly) ───────────
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
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
}
