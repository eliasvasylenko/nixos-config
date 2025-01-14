{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../users/eli.nix

    ../../system/base.nix
    ../../system/networking/wired.nix

    ../../services/authelia.nix
    ../../services/caddy.nix
    ../../services/fail2ban.nix
    ../../services/forgejo.nix
    ../../services/freeradius.nix
    ../../services/openldap.nix
    ../../services/ssh.nix
    ../../services/step-ca.nix
  ];

  boot.swraid.enable = true;
  boot.swraid.mdadmConf = ''
    MAILADDR=infrastructure@vasylenko.uk
  '';

  virtualisation.libvirtd.enable = true;

  services.immich = {
    enable = true;
    openFirewall = true;
    machine-learning.enable = false;
    port = 2283;
    host = "";
  };
  users.users.immich.extraGroups = [ "video" "render" ];
  services.caddy.virtualHosts."photos.determinist.vasylenko.uk".extraConfig = ''
    reverse_proxy = localhost:2283
  '';

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  users.users.eli = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
    ];
  };

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
  ];

  networking.firewall.allowedTCPPorts = [ 80 ];
  networking.firewall.enable = true;

  system.stateVersion = "24.05";
}

