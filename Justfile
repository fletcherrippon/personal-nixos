# Run these from the repo root inside the VM: `just <target>`

# Rebuild + activate the system config
switch:
    sudo nixos-rebuild switch --flake .#vm

# Build only (dry test that everything evaluates)
build:
    sudo nixos-rebuild build --flake .#vm

# Update all flake inputs (nixpkgs, home-manager, ...)
update:
    nix flake update

# Reload Hyprland after editing files in home/dotfiles/hypr (no rebuild needed)
reload:
    hyprctl reload
