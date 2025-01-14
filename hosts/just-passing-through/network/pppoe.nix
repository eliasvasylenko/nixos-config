{ config, lib, pkgs, hostName, ... }:

{
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
}