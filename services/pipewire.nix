{ config, pkgs, ... }:

{
  #services.dbus.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
    # systemWide = true; # does this break clear-air-turbulence?
  };
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
}
