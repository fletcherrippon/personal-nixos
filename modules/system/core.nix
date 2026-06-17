{ pkgs, ... }:
{
  # ── Boot (UEFI in UTM/QEMU aarch64) ────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest; # recent kernel = best virtio

  # ── Networking ─────────────────────────────────────────────────────
  networking.networkmanager.enable = true;

  # ── Locale / time (change to taste) ────────────────────────────────
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";

  # ── Fonts (mirrors your Mac) ───────────────────────────────────────
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-emoji
  ];

  # ── A couple of always-there CLI tools ─────────────────────────────
  environment.systemPackages = with pkgs; [ git vim wget ];

  # ── Nix ────────────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
}
