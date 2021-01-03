{
  description = "A small backup server running on a raspi 4B";

  inputs = {
    # Raspi 4 kernel is only on nixos-unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix.url = github:Mic92/sops-nix;
  };

  outputs = { self, nixpkgs, sops-nix, ... }:
    let
      # List of systems supported by this flake
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      # Function to generate set based on supported systems,
      # e.g. { x86_64-linux = f "x86_64-linux"; }
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Memoize nixpkgs for each supported system
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in {
      nixosConfigurations.minidepot = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./modules/base.nix
          ./modules/hardware-configuration.nix
          ./modules/restic-server.nix
          ./modules/sshd.nix
        ];
      };

      devShell = forAllSystems (system: let pkgs = nixpkgsFor.${system}; in pkgs.mkShell {
        sopsPGPKeyDirs = [ "./secrets/keys/hosts" "./secrets/keys/users" ];

        nativeBuildInputs = [
          sops-nix.packages.${system}.sops-pgp-hook
        ];
      });
    };
}
