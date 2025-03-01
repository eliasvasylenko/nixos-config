{ config, pkgs, ... }:

{
  services.immich = {
    enable = true;
    openFirewall = true;
    machine-learning.enable = false;
    port = 2283;
    host = "localhost";
  };
  users.users.immich.extraGroups = [ "video" "render" ];
  services.caddy.virtualHosts."photos.vasylenko.uk".extraConfig = ''
    reverse_proxy localhost:2283
  '';
}