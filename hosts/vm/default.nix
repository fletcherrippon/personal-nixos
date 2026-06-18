# VM host. The shared base comes from hosts/common.nix (added by the flake).
{ ... }:
{
  imports = [
    ./hardware-configuration.nix     # generated inside the VM
    ../../modules/system/vm.nix      # VM-only: guest tools + GL workaround
  ];

  networking.hostName = "nixos-vm";

  # Keep whatever release you installed; do NOT bump this on a whim.
  system.stateVersion = "26.05";
}
