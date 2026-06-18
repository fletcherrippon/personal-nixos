# Shared base for EVERY host (VM, Framework, …).
# Host-specific bits live in hosts/<name>/ and modules/system/<host>.nix.
{ inputs, isVM, ... }:
{
  imports = [
    ../modules/system/core.nix      # nix, boot, locale, networking, fonts, ssh
    ../modules/system/desktop.nix   # Hyprland, greeter, portals, graphics
    ../modules/system/audio.nix     # PipeWire
    ../modules/system/users.nix     # user account

    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit inputs isVM; };
    users.fletcher = import ../home;
  };
}
