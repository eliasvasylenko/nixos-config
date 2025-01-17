{ config, lib, pkgs, hostName, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./network

    ../../users/eli.nix

    ../../services/caddy/router.nix
    ../../services/ddclient.nix
    ../../services/ssh.nix

    ../../system/base.nix
  ];

  services.caddy.virtualHosts."lindsey.vasylenko.uk".extraConfig = ''
    respond "I love you!"
  '';
  services.caddy.virtualHosts."eli.vasylenko.uk".extraConfig = ''
    respond "I smell!"
  '';
  services.caddy.virtualHosts."rudy.vasylenko.uk".extraConfig = ''
    respond "I want to watch TV!"
  '';
  services.caddy.virtualHosts."router.vasylenko.uk".extraConfig = ''
    respond "Router dashboard..."
  '';
  services.caddy.virtualHosts."*.vasylenko.uk".extraConfig = ''
    tls {
      dns cloudflare {
        zone_token {file./var/lib/caddy/creds/cloudflare-zone-read}
        api_token {file./var/lib/caddy/creds/cloudflare-dns-edit}
      }
    }
    reverse_proxy https://determinist.lan.vasylenko.uk {
      transport http {
        tls_insecure_skip_verify
      }
    }
  '';
  systemd.services.caddy.serviceConfig.BindPaths = [
    "%d:/var/lib/caddy/creds"
  ];
  systemd.services.caddy.serviceConfig.LoadCredentialEncrypted = [
    "cloudflare-zone-read:/etc/credstore.encrypted/cloudflare-zone-read.cred"
    "cloudflare-dns-edit:/etc/credstore.encrypted/cloudflare-dns-edit.cred"
  ];

  system.stateVersion = "24.05";
}
