{ config, pkgs, ... }:

{
  services.immich = {
    enable = true;
    openFirewall = true;
    machine-learning.enable = false;
    port = 2283;
    host = "photos.vasylenko.uk";
  };
  users.users.immich.extraGroups = [ "video" "render" ];
  services.caddy.virtualHosts."photos.vasylenko.uk".extraConfig = ''
    tls internal
    reverse_proxy = localhost:2283
  '';
}