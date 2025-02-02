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
    ../../services/step-ca
  ];

  boot.swraid.mdadmConf = ''
    MAILADDR=infrastructure@vasylenko.uk
  '';

  virtualisation.libvirtd.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # the following is temporary, seemed necessary for some reason to turn it off...
  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  system.stateVersion = "24.05";
}

