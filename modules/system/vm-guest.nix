{ ... }:
{
  # Guest integration for the UTM/QEMU + SPICE backend:
  #   - shared clipboard between macOS host and the Linux guest
  #   - automatic display resize when you resize the VM window
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}
