nixpkgs:
{
  forEachSystem =
    systems: {nixpkgs, self}: function:
    nixpkgs.lib.genAttrs systems (
      system:
      function ({
        inherit system nixpkgs self;
        pkgs = import nixpkgs { inherit system; };
        }
      )
    );

  importNixFiles =
    path: args:
    with nixpkgs.lib;
    let
      allFiles = builtins.attrNames (filterAttrs (n: v: v == "regular") (builtins.readDir path));
      nixFiles = builtins.filter (strings.hasSuffix ".nix") allFiles;
      nixFileNames = builtins.map (strings.removeSuffix ".nix") nixFiles;
    in
    attrsets.genAttrs nixFileNames (regularFile: import "${path}/${regularFile}.nix" args);

  readDirs =
    path: function:
    with nixpkgs.lib;
    let
      allDirs = builtins.attrNames (filterAttrs (n: v: v == "directory") (builtins.readDir path));
    in
    attrsets.genAttrs allDirs function;
}
