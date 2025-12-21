self: with self.inputs.nixpkgs; rec {
  forEachSystem =
    systems: function:
    lib.genAttrs systems (
      system:
      function {
        inherit system self;
        pkgs = legacyPackages.${system};
      }
    );

  readNixFiles =
    path:
    let
      allFiles = builtins.attrNames (lib.filterAttrs (n: v: v == "regular") (builtins.readDir path));
    in
    lib.genAttrs allFiles (regularFile: "${path}/${regularFile}");

  importNixFiles = path: args: lib.mapAttrs (name: file: import file args) (readNixFiles path);

  readDirs =
    path: function:
    let
      allDirs = builtins.attrNames (lib.filterAttrs (n: v: v == "directory") (builtins.readDir path));
    in
    lib.genAttrs allDirs function;
}
