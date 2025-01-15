{ config, pkgs, ... }:

{
  services.authelia.instances.prod = {
    enable = true;
    secrets.jwtSecretFile = "$CREDENTIALS_DIRECTORY/jwt-secret";
    secrets.storageEncryptionKeyFile = "$CREDENTIALS_DIRECTORY/storage-encryption-key";
  };
  systemd.services.authelia.serviceConfig.LoadCredentialEncrypted = [
    "jwt-secret:/etc/credstore.encrypted/jwt-secret.cred"
    "storage-encryption-key:/etc/credstore.encrypted/storage-encryption-key.cred"
  ];
}