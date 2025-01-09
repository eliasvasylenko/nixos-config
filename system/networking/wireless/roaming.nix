{ config, pkgs, ... }:

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
      };
    };
    useDHCP = true;
    useNetworkd = true;
  };
}

