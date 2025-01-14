{ config, pkgs, ... }:

{
  services.step-ca = {
    enable = true;
    intermediatePasswordFile = "/etc/credstore.encrypted/ca-intermediate-password.cred";
  };
  systemd.services.step-ca.serviceConfig.LoadCredential = null;
  systemd.services.step-ca.serviceConfig.LoadEncryptedCredential = "intermediate_password:/etc/credstore.encrypted/ca-intermediate-password.cred";
}