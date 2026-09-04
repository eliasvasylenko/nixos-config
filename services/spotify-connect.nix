{ pkgs, ... }:
{
  # TODO update with pipewire stuff IFF pipewire is enabled

  users.groups.librespot = { };
  users.users.librespot = {
    isSystemUser = true;
    group = "librespot";
    extraGroups = [
      "audio"
      "pulse-access"
    ];
    home = "/var/lib/librespot";
    createHome = true;
  };

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
      ExecStart = "${pkgs.librespot}/bin/librespot --verbose --backend pulseaudio --name 'Kitchen Boogie' --device-type speaker --bitrate 320 --enable-volume-normalisation --zeroconf-port 4443";
      User = "librespot";
      Group = "librespot";
      StateDirectory = "librespot";
      # libmdns needs netlink to join 224.0.0.251
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      Restart = "always";
      RestartSec = 2;
    };
    wantedBy = [ "multi-user.target" ];
  };
  networking.firewall.allowedTCPPorts = [ 4443 ];
  networking.firewall.allowedUDPPorts = [ 5353 ];

  # IQ Engine drops Bonjour with IP TTL 1 (drop-bonjour-ttl-1) when
  # bridging eth0 backhaul to Wi-Fi. RFC 6762 requires TTL 1; STAs still
  # accept a higher TTL, which is the only way past that hard-coded drop.
  boot.kernelModules = [ "xt_HL" ];
  networking.firewall.extraCommands = ''
    iptables -w -t mangle -C OUTPUT -p udp --dport 5353 -d 224.0.0.251 -j TTL --ttl-set 255 2>/dev/null ||
      iptables -w -t mangle -A OUTPUT -p udp --dport 5353 -d 224.0.0.251 -j TTL --ttl-set 255
    ip6tables -w -t mangle -C OUTPUT -p udp --dport 5353 -d ff02::fb -j HL --hl-set 255 2>/dev/null ||
      ip6tables -w -t mangle -A OUTPUT -p udp --dport 5353 -d ff02::fb -j HL --hl-set 255
  '';
  networking.firewall.extraStopCommands = ''
    iptables -w -t mangle -D OUTPUT -p udp --dport 5353 -d 224.0.0.251 -j TTL --ttl-set 255 2>/dev/null || true
    ip6tables -w -t mangle -D OUTPUT -p udp --dport 5353 -d ff02::fb -j HL --hl-set 255 2>/dev/null || true
  '';
}
