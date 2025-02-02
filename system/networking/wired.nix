{ config, pkgs, ... }:

{
  networking = {
    firewall.enable = true;
    useNetworkd = true;
  };
}