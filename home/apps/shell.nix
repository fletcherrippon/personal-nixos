{ pkgs, ... }:
{
  # Mirrors the CLI setup from your nix-darwin home.nix.
  programs.zsh.enable = true;
  programs.starship.enable = true;
  programs.zoxide.enable = true;
  programs.fzf.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;   # per-project dev shells via flake.nix
  };

  programs.git = {
    enable = true;
    userName = "Fletcher Rippon";
    userEmail = "hello@fletcherrippon.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  home.packages = with pkgs; [
    lazygit
    bat
    eza
    ripgrep
    fd
    htop
    tree
    jq
    unzip
    gh
    neovim
  ];
}
