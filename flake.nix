{
  description = "NixOS Config vasylenko.uk";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, self, ... }:
    let
      forEachSystem = self.lib.forEachSystem [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      lib = import ./lib.nix self;
      nixosConfigurations = self.lib.readDirs ./hosts (
        hostName:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit self; };
          modules = [
            { networking.hostName = hostName; }
            ./hosts/${hostName}/configuration.nix
          ];
        }
      );
      devShells = forEachSystem (
        { system, ... }:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.step-cli
            ];
            shellHook = ''
              export STEPPATH=$(git rev-parse --show-toplevel)/services/step-ca
            '';
          };
        }
      );
    };
}
