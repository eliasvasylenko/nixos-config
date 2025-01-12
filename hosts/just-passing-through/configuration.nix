{ config, lib, pkgs, hostName, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../users/eli.nix

    ../../services/caddy.nix
    ../../services/ssh.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "console=ttyS0,38400"
  ];

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
  ];
  environment.variables.EDITOR = "nvim";

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;

    # source: https://github.com/mdlayher/homelab/blob/master/nixos/routnerr-2/configuration.nix#L52
    # By default, not automatically configure any IPv6 addresses.
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;

    # On WAN, allow IPv6 autoconfiguration and tempory address use.
    "net.ipv6.conf.wan.accept_ra" = 2;
    "net.ipv6.conf.wan.autoconf" = 1;
  };

  networking = {
    useDHCP = false;
    useNetworkd = true;

    nat.enable = false;
    firewall.enable = false;
  };

  services.resolved.enable = false;
  systemd.network = {
    enable = true;
    wait-online.enable = false;
    links = {
      "10-lan" = {
        matchConfig.MACAddress = "00:1a:8c:59:a3:e8";
        linkConfig.Name = "lan";
      };
      "20-wan" = {
        matchConfig.MACAddress = "00:1a:8c:59:a3:e9";
        linkConfig.Name = "wan";
      };
    };
    networks = {
      "30-lan" = {
        matchConfig.Name = "lan";
        linkConfig.RequiredForOnline = "yes";
        address = [ "192.168.10.1/24" ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
        };
      };
      "10-wan" = {
        matchConfig.Name = "wan";
        linkConfig.RequiredForOnline = "no";
        networkConfig = {
          DHCP = "ipv4";
          DNSOverTLS = true;
          DNSSEC = true;
          IPv6PrivacyExtensions = false;
          IPv4Forwarding = true;
          IPv6Forwarding = true;
        };
      };
    };
  };

  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        # enable flow offloading for better throughput
        #flowtable f {
        #  hook ingress priority 0;
        #  devices = { ppp0, lan };
        #}

        chain output {
          type filter hook output priority 0; policy accept;
        }

        chain input {
          type filter hook input priority 0; policy drop;

          tcp dport { 80, 443 } ct state new,established accept # Open HTTP(S) ports

          iifname "lan" accept comment "Allow trusted networks to access the router"

          iifname "ppp0" ct state { established, related } counter accept comment "Allow returning traffic from ppp0"
          iifname "ppp0" icmp type { echo-request, destination-unreachable, time-exceeded } counter accept comment "Allow select ICMP"
          iifname "ppp0" counter drop comment "Drop all other unsolicited traffic from wan"

          iifname "lo" accept comment "Accept everything from loopback interface"
        }

        chain forward {
          type filter hook forward priority 0; policy drop;

          iifname "ppp0" tcp flags syn tcp option maxseg size set rt mtu comment "MSS Clamping"
          oifname "ppp0" tcp flags syn tcp option maxseg size set rt mtu comment "MSS Clamping"

          #ip protocol { tcp, udp } flow offload @f comment "Enable flow offloading for better throughput"

          iifname "lan" oifname "ppp0" accept comment "Allow trusted LAN to WAN"
          iifname "ppp0" oifname "lan" ct state { established, related } accept comment "Allow established back to LANs"
        }
      }

      table ip nat {
        chain postrouting {
          type nat hook postrouting priority filter; policy accept;
          oifname "ppp0" masquerade comment "Setup NAT masquerading on the ppp0 interface"
        }
      }
    '';
  };

  services.pppd = {
    enable = true;
    peers = {
      bt = {
        autostart = true;
        enable = true;
        config = ''
          plugin pppoe.so wan

          name "bthomehub@btbroadband.com"
          password "BT"

          persist
          lcp-echo-interval 1
          lcp-echo-failure 4
          mtu 1412
          maxfail 0
          holdoff 5
          noipdefault
          hide-password
          defaultroute
        '';
      };
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      server = [ "1.1.1.1" "9.9.9.9" ];
      domain-needed = true;
      bogus-priv = true;
      no-resolv = true;

      cache-size = 1000;

      dhcp-range = [ "lan,192.168.10.50,192.168.10.254,24h" ];
      interface = [ "lan" "lo" ];
      dhcp-host = "192.168.10.1";

      local = "/lan.vasylenko.uk/";
      domain = "lan.vasylenko.uk,192.168.10.0/24";
      expand-hosts = true;

      no-hosts = true;
      address = [
        "/${hostName}.lan.vasylenko.uk/192.168.10.1"
        "/vasylenko.uk/192.168.10.1"
      ];
    };
  };

  services.caddy.virtualHosts."router.vasylenko.uk".extraConfig = ''
    respond "Hello, world!"
  '';

  services.cfdyndns = {
    enable = true;
    email = "elias@vasylenko.uk";
    apiTokenFile = "%d/apitoken";
    records = [ "vasylenko.uk" ];
  };
  systemd.services.cfdyndns.serviceConfig.ProtectSystem = "strict";
  systemd.services.cfdyndns.serviceConfig.LoadCredentialEncrypted = "apitoken:/etc/credstore.encrypted/cfdyndns-api-token.cred";

  system.stateVersion = "24.05";
}
