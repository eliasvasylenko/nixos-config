{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../users/eli.nix

    ../../system/base.nix
    ../../system/networking/wired.nix

    #../../services/authelia.nix
    ../../services/caddy/internal.nix
    ../../services/fail2ban.nix
    ../../services/forgejo.nix
    #../../services/freeradius.nix
    ../../services/immich.nix
    ../../services/openldap.nix
    ../../services/ssh.nix
    #../../services/step-ca.nix
  ];

  boot.swraid.mdadmConf = ''
    MAILADDR=infrastructure@vasylenko.uk
  '';

  virtualisation.libvirtd.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  system.stateVersion = "24.05";
}

