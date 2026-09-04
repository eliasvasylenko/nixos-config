{
  self,
  nixpkgs,
  system,
}:

nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit self; };
  modules = [ ./module.nix ];
}
