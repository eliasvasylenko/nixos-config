{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../users/eli.nix

    ../../system/base.nix
    ../../system/networking/wired.nix

    ../../programs/podman.nix
    
    ../../services/authelia.nix
    ../../services/caddy.nix
    ../../services/fail2ban.nix
    ../../services/forgejo.nix
    #../../services/freeradius.nix
    ../../services/immich.nix
    ../../services/jellyfin.nix
    ../../services/openldap.nix
    ../../services/phpldapadmin.nix
    ../../services/postgres.nix
    ../../services/ssh.nix
    ../../services/step-ca
  ];

  boot.swraid.mdadmConf = ''
    MAILADDR=infrastructure@vasylenko.uk
  '';

  virtualisation.libvirtd.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.caddy.virtualHosts."video.vasylenko.uk".extraConfig = ''
    reverse_proxy snoopy-badger.lan.vasylenko.uk
  '';

  # the following seems to be necessary for some reason to turn TPM off, otherwise the system will try to start with it but the hardware is not present...
  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

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
