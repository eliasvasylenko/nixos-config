{ config, pkgs, ... }:
{
  services.postgresql.enable = true;

  services.keycloak = {
    enable = true;

    database = {
      type = "postgresql";
      createLocally = true;
      username = "keycloak";
      passwordFile = "/var/lib/secret-agent/db_password";
    };

    settings = {
      hostname = "auth.vasylenko.uk";
      http-port = 38080;
      http-enabled = true;
    };
  };

  secret-agent.keys."keycloak/db_password" = {
    generate = [ "${pkgs.openssl}/bin/openssl" "rand" "-base64" "32" ];
    systemd.keycloak = {
      enable = true;
      bindPath = config.services.keycloak.database.passwordFile;
    };
    systemd.keycloakPostgreSQLInit = {
      enable = true;
      suppressUnencrypted = true;
    };
  };

  services.caddy.virtualHosts."auth.vasylenko.uk".extraConfig = ''
    reverse_proxy localhost:38080
  '';
}
