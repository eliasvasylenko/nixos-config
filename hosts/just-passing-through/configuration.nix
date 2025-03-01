{ config, lib, pkgs, hostName, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./network

    ../../users/eli.nix

    ../../services/caddy.nix
    #../../services/ddclient.nix
    ../../services/ssh.nix

    ../../system/base.nix
  ];

  environment.systemPackages = with pkgs; [
    nmap
  ];

  services.caddy.virtualHosts = {
    "lindsey.vasylenko.uk".extraConfig = ''
      respond "I love you!"
    '';
    "eli.vasylenko.uk".extraConfig = ''
      respond "I smell!"
    '';
    "rudy.vasylenko.uk".extraConfig = ''
      respond "I want to watch TV!"
    '';
    "router.vasylenko.uk".extraConfig = ''
      respond "Router dashboard..."
    '';
  };
  systemd.services.caddy.serviceConfig = {
    BindPaths = [ "%d:/var/lib/caddy/creds" ];
    LoadCredentialEncrypted = [
      "rfc2136:/etc/credstore.encrypted/rfc2136.cred"
    ];
  };

  system.stateVersion = "24.05";
}
