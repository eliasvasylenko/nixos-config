{ pkgs, config, ... }:
{
  services.bind = {
    enable = true;
    # named-checkconf runs in the sandbox and cannot see the TSIG
    # files LoadCredential mounts at /var/lib/bind/creds.
    checkConfig = false;
    forward = "first";
    forwarders = [ "1.1.1.1" "9.9.9.9" ];
    cacheNetworks = [ "127.0.0.0/24" "::1/128" "192.168.10.0/24" ];
    extraConfig = ''
      include "/var/lib/bind/creds/*";

      controls {
        inet 192.168.10.1 allow { cachenetworks; } keys {
          "just-passing-through.lan.vasylenko.uk";
          "determinist.lan.vasylenko.uk";
        };
      };

      zone "vasylenko.uk" {
        type primary;
        allow-query { cachenetworks; };
        allow-transfer {
          key just-passing-through.lan.vasylenko.uk;
          key determinist.lan.vasylenko.uk;
        };
        update-policy {
          grant just-passing-through.lan.vasylenko.uk zonesub a aaaa txt;
          grant determinist.lan.vasylenko.uk zonesub a aaaa txt;
        };
        file "/run/named/zones/zone-vasylenko.uk";
      };

      zone "10.168.192.in-addr.arpa" {
        type forward; 
        forward only;
        forwarders { 192.168.10.1 port 5353; };
      };

      zone "lan.vasylenko.uk" {
        type forward;
        forward only;
        forwarders { 192.168.10.1 port 5353; };
      };
    '';
  };
  systemd.services.bind.serviceConfig = {
    ExecStartPre = [
      "${pkgs.coreutils}/bin/mkdir -p /run/named/zones"
      "${pkgs.coreutils}/bin/cp -n ${pkgs.writeText "zone-vasylenko.uk" ''
        $ORIGIN vasylenko.uk.
        $TTL    1h
        @            IN      SOA     ns1 eli (
                                          1    ; Serial
                                          3h   ; Refresh
                                          1h   ; Retry
                                          1w   ; Expire
                                          1h)  ; Negative Cache TTL
                      IN      NS      ns1
                      IN      A       192.168.10.1

        ns1          IN      A       192.168.10.1

        $ORIGIN lan.vasylenko.uk.
        @            IN      NS      ns1.vasylenko.uk.
      ''} /run/named/zones/zone-vasylenko.uk"
    ];
    BindPaths = [ "%d:/var/lib/bind/creds" ];
    LoadCredentialEncrypted = [
      "just-passing-through-rfc2136:/etc/credstore.encrypted/just-passing-through-rfc2136.cred"
      "determinist-rfc2136:/etc/credstore.encrypted/determinist-rfc2136.cred"
    ];
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      port = 5353;
      domain-needed = true;
      bogus-priv = true;
      no-resolv = true;

      cache-size = 100;

      # Only DHCP server on this LAN. Short leases so a hostname
      # (busy-bee on wifi, then ethernet, then a reused address) does
      # not stick to a dead MAC for a day. dnsmasq gives the name to
      # the last client that sent it; the installer has three NICs.
      dhcp-authoritative = true;
      dhcp-range = [ "lan,192.168.10.50,192.168.10.254,1h" ];
      # Default is already 0; keep it explicit so BIND/resolved re-query.
      dhcp-ttl = 0;
      interface = [ "lan" "lo" ];
      dhcp-host = [
        "192.168.10.1"
        "c4:aa:c4:18:b7:ec,peepy-owl"
        "ec:71:db:8a:17:8d,chirpy-robin"
      ];
      dhcp-option = [ "6,192.168.10.1" ];

      local = "/lan.vasylenko.uk/";
      domain = "lan.vasylenko.uk,192.168.10.0/24";
      expand-hosts = true;

      no-hosts = true;
      address = [
        "/${config.networking.hostName}.lan.vasylenko.uk/192.168.10.1"
      ];
    };
  };
}
