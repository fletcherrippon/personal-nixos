{
  description = "Fletcher's NixOS VM (Apple Silicon / aarch64, Hyprland)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Optional upgrades (uncomment + wire in if you want them) ───────
    # Latest Hyprland, newer than what's in nixpkgs:
    # hyprland.url = "github:hyprwm/Hyprland";
    #
    # Zen browser. NOTE: its Linux builds are x86_64-only as of now, so this
    # likely WON'T build on aarch64 — Firefox is the ARM-native pick.
    # zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "aarch64-linux";
  in {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/vm

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.fletcher = import ./home;
        }
      ];
    };
  };
}
