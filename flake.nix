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
    {
      nixpkgs,
      nix-vscode-extensions,
      self,
    }@inputs:
    let
      forEachSystem = self.lib.forEachSystem [
        "x86_64-linux"
        "aarch64-linux"
      ] (inputs // { root = ./.; });
    in
    {
      lib = import ./nix/lib.nix nixpkgs;
      nixosConfigurations = self.lib.readDirs ./hosts (
        hostName:
        self.lib.nixosSystem {
          specialArgs = { inherit hostName self; };
          modules = [
            ./system/networking/hostName.nix
            ./hosts/${hostName}/configuration.nix
          ];
        }
      );
      devShells = forEachSystem (
        { pkgs, system }:
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.step-cli
              pkgs.nil
              pkgs.nixfmt-rfc-style
            ];
            shellHook = ''
              printf "VSCodium with extensions:\n"
              codium --list-extensions
              export STEPPATH=$(git rev-parse --show-toplevel)/services/step-ca
            '';
          };
        }
      );
    };
}
