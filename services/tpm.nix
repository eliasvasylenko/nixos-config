{ config, lib, pkgs, ... }:

{
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    abrmd.enable = true;
    tctiEnvironment.enable = true;
  };

  environment.systemPackages = with pkgs; [
    tpm2-tools
  ];
  
  users.users.eli.extraGroups = [ "tss" ];
}