{ ... }:
{
  networking = {
    firewall.enable = true;
    wireless = {
      iwd.enable = true;
      iwd.settings = {
        IPv6 = {
          Enabled = true;
        };
        Settings = {
          AutoConnect = true;
        };
        # Default is -70 dBm. Two HoppingFrog APs sit around -64..-76, so
        # iwd flaps every minute; each flap drops the DHCP lease (below).
        General = {
          RoamThreshold = -80;
          RoamThreshold5G = -80;
        };
      };
    };
    useDHCP = true;
    useNetworkd = true;
  };

  # iwd roam is a brief carrier blip. Without this, networkd drops the
  # DHCP lease and default route; OpenVPN's redirect-gateway then
  # blackholes its own UDP into tun0 until you restart the client.
  systemd.network.networks."99-wireless-client-dhcp" = {
    networkConfig.IgnoreCarrierLoss = "3s";
    dhcpV4Config.SendRelease = false;
  };

  # Do not flush OpenVPN host/default routes on DHCP renew.
  systemd.network.config.networkConfig = {
    ManageForeignRoutes = false;
    ManageForeignRoutingPolicyRules = false;
  };
}
