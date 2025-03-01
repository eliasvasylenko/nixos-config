{ lib, config, pkgs, ... }:

{
  services.step-ca = {
    enable = true;
    address = "localhost";
    port = 7443;
    openFirewall = true;
    settings = lib.importJSON ./config/ca.json;

    # We override the behaviour which uses this setting, but the service still expects it
    intermediatePasswordFile = "/dummy";
  };
  # This replaces the intermediatePasswordFile with an encrypted version
  systemd.services.step-ca.serviceConfig.LoadCredential = lib.mkForce null;
  systemd.services.step-ca.serviceConfig.LoadCredentialEncrypted = [
    "intermediate_password:/etc/credstore.encrypted/ca-intermediate-password.cred"
  ];
  services.caddy.virtualHosts."ca.vasylenko.uk".extraConfig = ''
    tls eli@vasylenko.uk {
      ca https://localhost:7443/acme/acme/directory
      ca_root ${../../system/certs/root_ca.crt}
    }
    reverse_proxy localhost:7443 {
      transport http {
        tls_trusted_ca_certs ${../../system/certs/root_ca.crt}
      }
    }
  '';
  environment.etc."smallstep/certs".source = ./certs;
  environment.etc."smallstep/templates".source = ./templates;
  environment.etc."smallstep/secrets/intermediate_ca_key".source = ./secrets/intermediate_ca_key;
}