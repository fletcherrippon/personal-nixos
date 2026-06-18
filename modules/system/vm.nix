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
}
