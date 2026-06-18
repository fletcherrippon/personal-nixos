# Deploying this config to the Framework laptop

This repo is **multi-host**. The VM and the Framework share everything except a
small set of host-specific bits, selected by the `isVM` flag in `flake.nix`.

## What's shared (works on every host)
- `modules/system/{core,desktop,audio,users}.nix`
- All of `home/` — Hyprland, the eww bar, waybar, the theme system, the shell

## What's VM-only (NOT used on the Framework)
- `modules/system/vm.nix` — qemu/spice guest tools + `GDK_DEBUG=gl-gles`
- The `term` wrapper forces software GL **only when `isVM = true`**
- `~/.config/hypr-host/host.conf` (generated) — `no_hardware_cursors` + the
  fixed `1800x1169` resolution

With `isVM = false`, none of those apply: Ghostty runs on native GL, there are
no GL workarounds, and the guest tools are absent.

## Steps for the Framework
1. Boot the **x86_64** NixOS installer; partition + mount.
2. `sudo nixos-generate-config --root /mnt`, then copy the generated
   `hardware-configuration.nix` into `hosts/framework/`.
3. Add `nixos-hardware` to `flake.nix` inputs, and uncomment the `framework`
   block in `nixosConfigurations` (it's already stubbed there).
4. Create `hosts/framework/default.nix`:
   ```nix
   { inputs, ... }:
   {
     imports = [
       ./hardware-configuration.nix
       inputs.nixos-hardware.nixosModules.framework-13-7040-amd  # pick your model
     ];
     networking.hostName = "framework";
     system.stateVersion = "26.05";
   }
   ```
5. Clone this repo to `~/personal-nixos`, then
   `sudo nixos-install --flake ~/personal-nixos#framework`.

## Optional: the performance stack (bare metal only)
This is where the CachyOS-style tuning you asked about early on actually pays off
(it was pointless in the VM):
- `chaotic-nyx` flake → `linuxPackages_cachyos`, `scx` schedulers
- `services.scx.enable`, `services.ananicy.enable`
- (zram is already on, in `core.nix`)

When you're ready, we'll add a `modules/system/performance.nix` and import it
from `hosts/framework` only.
