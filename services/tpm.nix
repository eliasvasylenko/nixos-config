{ lib, pkgs, ... }:
{
  security.tpm2 = {
    enable = true;
    pkcs11 = {
      enable = true;
    };
    abrmd.enable = lib.mkDefault true;
    tctiEnvironment.enable = true;
    tctiEnvironment.interface = lib.mkDefault "tabrmd";
  };

  environment.systemPackages = with pkgs; [
    tpm2-tools
    tpm2-openssl
  ];

  users.users.eli.extraGroups = [ "tss" ];
}
