{
  pkgs,
  config,
  ...
}:
let
  # TSIG key names still match the pre-rename hostnames in credstore.
  tsigName =
    {
      eager-beaver = "just-passing-through";
      little-donkey = "determinist";
    }
    .${config.networking.hostName} or config.networking.hostName;
in
{
  services.caddy = {
    enable = true;
    logFormat = ''
      level DEBUG
    '';
    package = (pkgs.caddy.withPlugins {
      plugins = [
        # v0.1.2 still uses the old libdns.Record struct
        "github.com/caddy-dns/rfc2136@v1.0.1-0.20250502132027-e50b9f25dd68"
        "github.com/mholt/caddy-dynamicdns@v0.0.0-20260805195708-67d107a42c02"
      ];
      hash = "sha256-urC33IjpESGjxVS1+mYJmjgbGDTcStF0RKJl4pBk4JA=";
    });
    globalConfig = ''
      email eli@vasylenko.uk
      cert_issuer acme https://ca.vasylenko.uk/acme/acme/directory {
        trusted_roots ${../system/certs/root_ca.crt}
      }
      acme_ca https://ca.vasylenko.uk/acme/acme/directory
      acme_ca_root ${../system/certs/root_ca.crt}
      acme_dns rfc2136 {
        key_name "${tsigName}.lan.vasylenko.uk"
        key_alg "hmac-sha512"
        key "{file./var/lib/caddy/creds/rfc2136}"
        server "ns1.vasylenko.uk:53"
      }
      dynamic_dns {
        provider rfc2136 {
          key_name "${tsigName}.lan.vasylenko.uk"
          key_alg "hmac-sha512"
          key "{file./var/lib/caddy/creds/rfc2136}"
          server "ns1.vasylenko.uk:53"
        }
        ip_source interface lan
        include 192.168.10.0/24
        ttl 1h
    		check_interval 5m
        domains {
          vasylenko.uk
        }
  			dynamic_domains
      }
    '';
  };
  systemd.services.caddy.serviceConfig = {
    BindPaths = [ "%d:/var/lib/caddy/creds/" ];
    LoadCredentialEncrypted = [
      "rfc2136:/etc/credstore.encrypted/rfc2136.cred"
    ];
  };

  # TODO systemd.services.caddy.serviceConfig.ProtectSystem = "strict";
}
