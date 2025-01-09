{ config, pkgs, ... }:

{
  # TODO update with pipewire stuff IFF pipewire is enabled

  systemd.services.spotify-connect-receiver = {
    enable = true;
    description = "Spotify Connect Receiver Using librespot";
    unitConfig = {
      #Requires = [ "network-online.target" "pipewire.service" ];
      #After = [ "network-online.target" "pipewire.service" ];
      Requires = [ "network-online.target" ];
      After = [ "network-online.target" ];
    };
    environment.HOME = "/var/lib/librespot";
    serviceConfig = {
      ExecStart = "${pkgs.librespot}/bin/librespot --name 'Kitchen Boogie' --device-type speaker --bitrate 320 --enable-volume-normalisation --zeroconf-port 4443";
      DynamicUser = true;
      Group = "librespot";
      #ExtraGroups = [ "pipewire" ];
      Restart = "always";
      RestartSec = 2;
    };
    wantedBy = [ "multi-user.target" ];
  };
  networking.firewall.allowedTCPPorts = [ 4443 ];
  networking.firewall.allowedUDPPorts = [ 5353 ];
}
