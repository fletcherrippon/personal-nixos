{ pkgs, ... }:
{
  # ── Boot (UEFI in UTM/QEMU aarch64) ────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest; # recent kernel = best virtio

  # ── Networking ─────────────────────────────────────────────────────
  networking.networkmanager.enable = true;

  # ── Locale / time ──────────────────────────────────────────────────
  # Timezone auto-set from your IP (great for travelling). Runs on boot and
  # when the network comes up; force it anytime with `sudo tzupdate`. In a VM
  # this beats geoclue (no Wi-Fi/GPS to scan). Don't also set time.timeZone.
  services.tzupdate.enable = true;

  # Locale is a personal preference, not location — keep it Australian so your
  # date/number formats don't change as you travel.
  i18n.defaultLocale = "en_AU.UTF-8";
  console.keyMap = "us";

  # ── Fonts (mirrors your Mac) ───────────────────────────────────────
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  # ── A couple of always-there CLI tools ─────────────────────────────
  environment.systemPackages = with pkgs; [ git vim wget tzupdate ];

  # ── Compressed RAM swap (smoother under memory pressure) ───────────
  # Trades a little CPU (fast on M3) to avoid slow disk swap stalls.
  zramSwap.enable = true;

  # ── Nix ────────────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
}
