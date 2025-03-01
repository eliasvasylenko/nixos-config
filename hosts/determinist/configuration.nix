{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../users/eli.nix

    ../../system/base.nix
    ../../system/networking/wired.nix

    #../../services/authelia.nix
    ../../services/caddy.nix
    ../../services/fail2ban.nix
    ../../services/forgejo.nix
    #../../services/freeradius.nix
    ../../services/immich.nix
    ../../services/jellyfin.nix
    ../../services/openldap.nix
    ../../services/ssh.nix
    ../../services/step-ca
  ];

  boot.swraid.mdadmConf = ''
    MAILADDR=infrastructure@vasylenko.uk
  '';

  virtualisation.libvirtd.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  system.stateVersion = "24.05";

  systemd.network = {
    links = {
      "10-lan" = {
        matchConfig.MACAddress = "00:90:fa:e6:f7:62";
        linkConfig.Name = "lan";
      };
    };
    networks = {
      "30-lan" = {
        matchConfig.Name = "lan";
        networkConfig.DHCP = "yes";
        linkConfig.RequiredForOnline = "yes";
      };
    };
  };
}

