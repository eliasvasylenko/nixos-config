{ config, pkgs, ... }:

{
  services.ddclient = {
    enable = true;
    passwordFile = "$CREDENTIALS_DIRECTORY/cloudflare-dns-edit";
    domains = [ "vasylenko.uk" "*.vasylenko.uk" ];
    zone = "vasylenko.uk";
    protocol = "cloudflare";
    usev4 = "if, if=ppp0";
    usev6 = "if, if=ppp0";
  };
  systemd.services.cfdyndns.serviceConfig.ProtectSystem = "strict";
  systemd.services.ddclient.serviceConfig.LoadCredentialEncrypted = [
    "cloudflare-dns-edit:/etc/credstore.encrypted/cloudflare-dns-edit.cred"
  ];
}