{ lib, pkgs, config, ... }:

let
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
    Host *.lan.vasylenko.uk
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
