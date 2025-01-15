{ config, lib, pkgs, hostName, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./network

    ../../users/eli.nix

    ../../services/caddy.nix
    ../../services/ddclient.nix
    ../../services/ssh.nix

    ../../system/base.nix
  ];

  services.caddy.virtualHosts."lindsey.vasylenko.uk".extraConfig = ''
    respond "I love you!"
  '';
  services.caddy.virtualHosts."eli.vasylenko.uk".extraConfig = ''
    respond "I smell!"
  '';
  services.caddy.virtualHosts."rudy.vasylenko.uk".extraConfig = ''
    respond "I want to watch TV!"
  '';

  system.stateVersion = "24.05";
}
