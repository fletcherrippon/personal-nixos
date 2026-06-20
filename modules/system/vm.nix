# VM-ONLY system config. Imported only by hosts/vm — NEVER by bare-metal hosts,
# so none of these workarounds follow you to the Framework.
{ ... }:
{
  # QEMU/SPICE guest integration: shared clipboard + display auto-resize.
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # virgl in the VM only exposes desktop GL 2.1, so push GTK apps onto GLES.
  # Real hardware has full OpenGL, so this lives in the VM module only.
  environment.sessionVariables.GDK_DEBUG = "gl-gles";

  # Force the virtio-gpu framebuffer size at the kernel DRM level. UTM's SPICE
  # dynamic-resolution handshake (VDAgentMonitorsConfig) is broken on Wayland,
  # so it locks the framebuffer at a default 1280x800 and ignores window
  # resizes AND in-guest mode-sets. `video=` runs at kernel init, underneath
  # SPICE, so it can size the scanout when nothing else can. Pair with UTM
  # "Resize display to window size automatically" OFF so SPICE can't re-assert.
  boot.kernelParams = [ "video=Virtual-1:1920x1200" ];
}
