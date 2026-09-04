{
  description = "NixOS Config vasylenko.uk";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };
  };

  outputs =
    {
      nixpkgs,
      self,
      nixos-anywhere,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      forEachSystem = self.lib.forEachSystem [
        "x86_64-linux"
        "aarch64-linux"
      ];
      writeInstaller =
        pkgs:
        pkgs.writeShellApplication {
          name = "write-installer";
          runtimeInputs = [
            pkgs.coreutils
            pkgs.git
            pkgs.gawk
            pkgs.gptfdisk
            pkgs.nix
            pkgs.util-linux
          ];
          text = builtins.readFile ./installer/write-installer.sh;
        };
      installHost =
        pkgs:
        pkgs.writeShellApplication {
          name = "install-host";
          runtimeInputs = [
            pkgs.git
            nixos-anywhere.packages.${pkgs.stdenv.hostPlatform.system}.nixos-anywhere
          ];
          text = builtins.readFile ./installer/install-host.sh;
        };
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
      packages = forEachSystem (
        { system, ... }:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          write-installer = writeInstaller pkgs;
          install-host = installHost pkgs;
        }
        // lib.optionalAttrs (system == "x86_64-linux") {
          installer =
            (import ./installer {
              inherit self nixpkgs system;
            }).config.system.build.isoImage;
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
              (writeInstaller pkgs)
              (installHost pkgs)
            ];
            shellHook = ''
              export STEPPATH=$(git rev-parse --show-toplevel)/services/step-ca
            '';
          };
        }
      );
    };
}
