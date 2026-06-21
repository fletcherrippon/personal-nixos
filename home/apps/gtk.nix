# System-wide dark mode.
#
# The key signal is the XDG "color-scheme: prefer-dark" preference. With
# xdg-desktop-portal-gtk running, it's published on org.freedesktop.appearance,
# and GTK4/libadwaita (nautilus), Firefox, and Electron/Ozone apps read it and
# go dark automatically. The dark GTK3 theme covers older GTK3 apps that don't
# follow the portal on their own.
{ pkgs, ... }:
{
  # The portal/appearance "prefer dark" signal (read via gsettings/dconf).
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  gtk = {
    enable = true;

    # Dark GTK3 theme so GTK3 apps match the libadwaita dark look.
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    # Belt-and-suspenders: ask GTK directly for the dark variant.
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };
}
