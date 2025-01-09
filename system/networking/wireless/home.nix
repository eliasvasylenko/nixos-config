{ config, pkgs, ... }:

{
  networking = {
    firewall.enable = true;
    wireless = {
      enable = true;
      userControlled.enable = false;
      networks = {
        "HoppingRabbit" = {
          pskRaw = "fbee9e511924d6036a27d37be37d7c3f16575af2d1cf7827d2859f13d93ead4d";
        };
      };
    };
    useDHCP = true;
    useNetworkd = true;
  };
}

