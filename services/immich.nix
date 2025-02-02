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
    tls eli@vasylenko.uk {
        ca https://ca.vasylenko.uk/acme/acme/directory
        ca_root ${../system/certs/root_ca.crt}
        client_auth {
            mode require_and_verify
            trusted_ca_cert_file ${../system/certs/root_ca.crt}
        }
    }
    reverse_proxy = localhost:2283
  '';
}