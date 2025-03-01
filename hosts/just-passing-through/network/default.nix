{ config, lib, pkgs, hostName, ... }:

{
  imports = [
    ./dns.nix
    ./firewall.nix
    ./pppoe.nix
  ];

  networking = {
    useDHCP = false;
    useNetworkd = false;

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
}