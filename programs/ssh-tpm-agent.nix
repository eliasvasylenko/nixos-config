{ self, lib, pkgs, config, ... }:

let
  hostNames = builtins.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir (self + "/hosts"))
  );
  hostAliases = lib.concatMapStringsSep " " (
    name: "${name} ${name}.lan.vasylenko.uk"
  ) hostNames;
  pkcs11 = "/run/current-system/sw/lib/libtpm2_pkcs11.so";
  pkcs11Lib = "${config.security.tpm2.pkcs11.package}/lib";
  pkcs11StoreFiles = map (name: "${pkcs11Lib}/${name}") (
    builtins.attrNames (
      lib.filterAttrs (name: _: lib.hasPrefix "libtpm2_pkcs11.so" name) (
        builtins.readDir pkcs11Lib
      )
    )
  );
  pkcs11Whitelist = lib.concatStringsSep "," (pkcs11StoreFiles ++ [ pkcs11 ]);
in
{
  programs.ssh.extraConfig = ''
    Host ${hostAliases}
      ForwardAgent yes
  '';

  # ssh-agent runs this script again as its child (SOCK already set).
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "tpm-agent";
      runtimeInputs = [ pkgs.openssh ];
      text = ''
        pkcs11=${lib.escapeShellArg pkcs11}
        whitelist=${lib.escapeShellArg pkcs11Whitelist}
        if [[ "''${1:-}" != --inside ]]; then
          exec ssh-agent -P "$whitelist" "$0" --inside "$@"
        fi
        shift
        ssh-add -s "$pkcs11"
        if [[ $# -gt 0 ]]; then
          exec "$@"
        fi
        exec "''${SHELL:-bash}"
      '';
    })
  ];
}
