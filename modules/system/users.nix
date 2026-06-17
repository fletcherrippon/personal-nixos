{ pkgs, ... }:
{
  programs.zsh.enable = true;

  users.users.fletcher = {
    isNormalUser = true;
    description = "Fletcher";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.zsh;

    # ⚠️ Throwaway VM password — CHANGE IT after first login with `passwd`.
    initialPassword = "nixos";
  };
}
