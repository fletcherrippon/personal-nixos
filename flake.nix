{
  description = "Fletcher's NixOS — multi-host (VM now, Framework later)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── For the Framework laptop (uncomment when deploying) ────────────
    # nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    # Build a host from the shared base (hosts/common.nix) + host modules.
    # `isVM` flips VM-only behaviour (software GL, guest tools, etc.).
    mkSystem = { system, isVM, modules }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs isVM; };
        modules = [ ./hosts/common.nix ] ++ modules;
      };
  in {
    nixosConfigurations = {
      vm = mkSystem {
        system = "aarch64-linux";
        isVM = true;
        modules = [ ./hosts/vm ];
      };

      # ── Framework laptop (x86_64, bare metal). See FRAMEWORK.md. ──────
      # framework = mkSystem {
      #   system = "x86_64-linux";
      #   isVM = false;
      #   modules = [ ./hosts/framework ];
      # };
    };
  };
}
