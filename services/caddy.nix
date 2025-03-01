{
  pkgs,
  hostName,
  ...
}: {
  # tsig-keygen -a hmac-sha512 determinist.vasylenko.uk
  services.caddy = {
    enable = true;
    logFormat = ''
      level DEBUG
    '';
    package = (pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/rfc2136@v0.1.2"
        "github.com/eliasvasylenko/caddy-dynamicdns@v0.0.0-20250227123441-95b5f2944cac"
      ];
      hash = "sha256-5RsLgnT7Xuf1B3Wfkw7SeBIJbTqismQW43oxG3V9jRA=";
    });
    globalConfig = ''
      email eli@vasylenko.uk
      cert_issuer acme https://ca.vasylenko.uk/acme/acme/directory {
        trusted_roots ${../system/certs/root_ca.crt}
      }
      acme_ca https://ca.vasylenko.uk/acme/acme/directory
      acme_ca_root ${../system/certs/root_ca.crt}
      acme_dns rfc2136 {
        key_name "${hostName}.lan.vasylenko.uk"
        key_alg "hmac-sha512"
        key "{file./var/lib/caddy/creds/rfc2136}"
        server "ns1.vasylenko.uk:53"
      }
      dynamic_dns {
        provider rfc2136 {
          key_name "${hostName}.lan.vasylenko.uk"
          key_alg "hmac-sha512"
          key "{file./var/lib/caddy/creds/rfc2136}"
          server "ns1.vasylenko.uk:53"
        }
        ip_source interface lan
        includes 192.168.10.0/24
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
    BindPaths = [ "%d:/var/lib/caddy/creds" ];
    LoadCredentialEncrypted = [
      "rfc2136:/etc/credstore.encrypted/rfc2136.cred"
    ];
  };
  # TODO systemd.services.caddy.serviceConfig.ProtectSystem = "strict";
}
