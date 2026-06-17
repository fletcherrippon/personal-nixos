{ ... }:
{
  imports = [
    ./hardware-configuration.nix          # generated inside the VM (see file)
    ../../modules/system/core.nix         # nix, boot, locale, networking, fonts
    ../../modules/system/desktop.nix      # Hyprland, greeter, portals, graphics
    ../../modules/system/audio.nix        # PipeWire
    ../../modules/system/vm-guest.nix     # clipboard + display auto-resize
    ../../modules/system/users.nix        # your user account
  ];

  networking.hostName = "nixos-vm";

  # Keep whatever release you installed; do NOT bump this on a whim.
  system.stateVersion = "26.05";
}
