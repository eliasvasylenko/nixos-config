{
  description = "NixOS Config vasylenko.uk";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    with nixpkgs.lib;
    let
      hostNames = builtins.attrNames
        (filterAttrs (n: v: v == "directory")
	(builtins.readDir ./hosts));
      hosts = attrsets.genAttrs hostNames (hostName: nixosSystem {
        modules = [
          ({ ... }: { networking.hostName = hostName; })
          ./hosts/${hostName}/configuration.nix
        ];
      });
      devSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = function:
        genAttrs devSystems (system: function (rec {
          inherit system;
          pkgs = nixpkgs.legacyPackages.${system};
          extensions = inputs.nix-vscode-extensions.extensions.${system};
        }));
    in
    {
      nixosConfigurations = hosts;
      devShells = forAllSystems ({pkgs, system, extensions}: {
        default = pkgs.mkShell {
          buildInputs = [
            (pkgs.vscode-with-extensions.override {
              vscode = pkgs.vscodium;
              vscodeExtensions = [
                extensions.open-vsx.jnoortheen.nix-ide
              ];
            })
          ];
          shellHook = ''
            printf "VSCodiumsss with extensions:\n"
            codium --list-extensions
          '';
        };
      });
    };
}
