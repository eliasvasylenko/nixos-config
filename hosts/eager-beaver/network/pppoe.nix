{ lib, config, ... }:
{
  services.pppd = {
    enable = true;
    peers = {
      openreach = {
        autostart = true;
        enable = true;
        config = ''
          plugin pppoe.so wan

          name "eli.vasylenko@olilo.uk"
          password "9ZgmQamDqjbLu61V"

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

  # Type=notify + up_sdnotify: systemd waits for IPCP. Default 90s
  # TimeoutStartSec SIGTERMs pppd mid-retry during an ISP flap.
  systemd.services = lib.mapAttrs' (name: _:
    lib.nameValuePair "pppd-${name}" {
      serviceConfig.TimeoutStartSec = "infinity";
    }
  ) config.services.pppd.peers;
}
