{ config, ... }:
{
  networking = {
    firewall.enable = true;
    useDHCP = false;
  };

  systemd.network = {
    enable = true;
    # Hosts that rename NICs (e.g. lan) add an earlier unit and win.
    # USB Ethernet sometimes gets eth0 rather than en*.
    networks."20-wired" = {
      matchConfig.Name = "enp*";
      networkConfig.DHCP = "ipv4";
      dhcpV4Config = {
        SendHostname = true;
        Hostname = config.networking.hostName;
      };
      linkConfig.RequiredForOnline = "routable";
    };
    wait-online.anyInterface = true;
  };
}
