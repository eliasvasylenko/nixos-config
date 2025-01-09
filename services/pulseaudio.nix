{ config, pkgs, ... }:

{
  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
    extraConfig = ''
      unload-module module-native-protocol-unix
      load-module module-native-protocol-unix auth-anonymous=1
    '';
  };
}
