{ config, pkgs, ... }:

{
  services.ddclient = {
    enable = true;
    passwordFile = "$CREDENTIALS_DIRECTORY/cloudflare-ddclient-password";
    domains = [ "vasylenko.uk" "*.vasylenko.uk" ];
    zone = "vasylenko.uk";
    protocol = "cloudflare";
    use = "if, if=ppp0";
  };
  systemd.services.cfdyndns.serviceConfig.ProtectSystem = "strict";
  systemd.services.ddclient.serviceConfig.LoadCredentialEncrypted = "cloudflare-ddclient-password:/etc/credstore.encrypted/cloudflare-ddclient-password.cred";
}