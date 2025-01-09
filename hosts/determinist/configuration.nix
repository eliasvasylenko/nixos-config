# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../users/eli.nix

    ../../system/base.nix
    ../../system/networking/wired.nix

    ../../services/caddy.nix
    ../../services/forgejo.nix
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

