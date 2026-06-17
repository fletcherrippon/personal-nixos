# personal-nixos — Hyprland VM (Apple Silicon)

A modular NixOS config for an **aarch64 VM** on Apple Silicon (M3 Max), running a
hand-built **Hyprland** Wayland desktop. The compositor and a few system bits are
declared in Nix; the *rice* (Hyprland/waybar/fuzzel/mako) lives as ordinary,
editable config files so you can tweak and `hyprctl reload` instantly.

## Layout

```
flake.nix                     # entry point; wires nixpkgs + home-manager
Justfile                      # `just switch`, `just update`, `just reload`
hosts/
  vm/
    default.nix               # host: imports modules, hostname, stateVersion
    hardware-configuration.nix # PLACEHOLDER — generate inside the VM
modules/
  system/
    core.nix                  # nix, boot, locale, networking, fonts
    desktop.nix               # Hyprland, greetd greeter, portals, graphics
    audio.nix                 # PipeWire
    vm-guest.nix              # clipboard + display auto-resize
    users.nix                 # your user account
home/
  default.nix                 # home-manager: desktop packages + config symlinks
  apps/
    shell.nix                 # zsh/starship/git/etc (mirrors your Mac)
  dotfiles/                   # ← edit these live; reload without rebuilding
    hypr/
      hyprland.conf           # sources everything in conf.d/
      hyprlock.conf
      hypridle.conf
      conf.d/                 # env, monitors, input, appearance, autostart,
                              # keybinds, rules — one concern per file
    waybar/  (config.jsonc, style.css)
    fuzzel/  (fuzzel.ini)
    mako/    (config)
```

## Install (UTM, QEMU backend)

1. Download the **aarch64 minimal ISO** from nixos.org.
2. UTM → New → **Virtualize → Linux**, **QEMU** backend. Give it ~8 GB RAM,
   4–6 CPUs, ~40 GB disk, UEFI on, and enable hardware OpenGL (virtio-gpu-gl).
3. Boot the ISO. Partition + format a GPT disk (ESP + root), mount root at
   `/mnt` and the ESP at `/mnt/boot`.
4. Generate hardware config and clone this repo:
   ```sh
   sudo nixos-generate-config --root /mnt
   nix-shell -p git   # ISO has git; or use the one in PATH
   git clone <your-repo-url> /mnt/home/fletcher/personal-nixos
   cp /mnt/etc/nixos/hardware-configuration.nix \
      /mnt/home/fletcher/personal-nixos/hosts/vm/hardware-configuration.nix
   ```
5. Install from the flake:
   ```sh
   sudo nixos-install --flake /mnt/home/fletcher/personal-nixos#vm
   ```
6. Reboot. Log in at the greeter (user `fletcher`, password `nixos`),
   **then change it: `passwd`.**

> The repo MUST end up at `~/personal-nixos` inside the VM — the live-edit
> symlinks in `home/default.nix` point there. After first boot, future changes
> are just: edit files → `just switch` (or `just reload` for Hyprland-only).

## Keybindings (SUPER = Cmd key)

| Keys | Action |
|------|--------|
| `Super` `Enter` | Terminal (ghostty) |
| `Super` `R` | App launcher (fuzzel) |
| `Super` `B` / `C` / `E` | Browser / editor (Zed) / files |
| `Super` `Q` | Close window |
| `Super` `F` / `V` | Fullscreen / toggle floating |
| `Super` arrows or `h/j/k/l` | Move focus |
| `Super` `Shift` arrows | Move window |
| `Super` `1..5` | Switch workspace (`+Shift` = move window there) |
| `Print` | Screenshot a region → clipboard |
| `Super` `.` | Clipboard history |
| `Super` `Escape` | Lock screen |
| `Super` `M` | Log out of Hyprland |

## Tweaking (the fun part)

- **Hyprland look/behaviour:** edit `home/dotfiles/hypr/conf.d/*.conf`, then
  `hyprctl reload`. Start with `appearance.conf` (gaps, rounding, blur, border
  colours) and `keybinds.conf`.
- **Bar:** `home/dotfiles/waybar/` — `config.jsonc` for modules, `style.css`
  for the look. Restart it with `killall waybar && waybar &` or re-login.
- **Colours** here are the Catppuccin Mocha palette (`#1e1e2e`, `#89b4fa`, …).

## Notes / gotchas

- **Performance:** if the desktop feels sluggish, disable blur in
  `appearance.conf` (`blur { enabled = false }`). VM GL is software-assisted.
- **Image wallpaper:** swap `swaybg` for `swww` in `home/default.nix` +
  `autostart.conf` (`swww-daemon` then `swww img ~/wall.png`).
- **Zen browser:** its Linux builds are x86_64-only, so this ARM VM uses
  Firefox (same engine). Revisit if an aarch64 Zen build appears.
- **Add a second WM later:** install e.g. `niri`, and pick it at the greeter —
  no reinstall, your Hyprland setup stays put.
- **More speed?** Native bare-metal Linux via the `nixos-apple-silicon` (Asahi)
  flake is the only thing faster than this VM, but it's a much bigger commitment
  and M3 support is newer. Overkill for testing.
