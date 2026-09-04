{ pkgs, ... }:
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

  secret-agent."keycloak/db_password" = {
    create = [ "${pkgs.openssl}/bin/openssl" "rand" "-base64" "32" ];
    systemd.enable = true;
  };

  services.caddy.virtualHosts."auth.vasylenko.uk".extraConfig = ''
    reverse_proxy localhost:38080
  '';
}
