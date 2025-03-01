{ config, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  services.caddy.virtualHosts."stream.vasylenko.uk".extraConfig = ''
    reverse_proxy localhost:8096
  '';
}
