{ pkgs, ... }:
{
  # TODO update with pipewire stuff IFF pipewire is enabled

  systemd.services.spotify-connect-receiver = {
    enable = true;
    description = "Spotify Connect Receiver Using librespot";
    after = [
      "network-online.target"
      "pulseaudio.service"
    ];
    wants = [ "network-online.target" ];
    requires = [ "pulseaudio.service" ];
    environment = {
      HOME = "/var/lib/librespot";
      PULSE_SERVER = "unix:/run/pulse/native";
      PULSE_RUNTIME_PATH = "/run/pulse";
    };
    serviceConfig = {
      ExecStart = "${pkgs.librespot}/bin/librespot --backend pulseaudio --name 'Kitchen Boogie' --device-type speaker --bitrate 320 --enable-volume-normalisation --zeroconf-port 4443";
      DynamicUser = true;
      StateDirectory = "librespot";
      SupplementaryGroups = [
        "audio"
        "pulse-access"
      ];
      Restart = "always";
      RestartSec = 2;
    };
    wantedBy = [ "multi-user.target" ];
  };
  networking.firewall.allowedTCPPorts = [ 4443 ];
  networking.firewall.allowedUDPPorts = [ 5353 ];
}
