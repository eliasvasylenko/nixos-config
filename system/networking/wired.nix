{ config, pkgs, ... }:

{
  networking = {
    firewall.enable = true;
    useDHCP = false;
  };

  systemd.network = {
    enable = true;
  };
}