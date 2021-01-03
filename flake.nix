{
  description = "A small backup server running on a raspi 4B";

  inputs = {
    # Raspi 4 kernel is only on nixos-unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.minidepot = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./modules/base.nix
        ./modules/hardware-configuration.nix
        ./modules/restic-server.nix
        ./modules/sshd.nix
      ];
    };
  };
}
