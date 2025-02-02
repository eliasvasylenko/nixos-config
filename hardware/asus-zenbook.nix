{ config, pkgs, ... }:

{
  imports = [
    ./nvidia.nix
  ];

  nixpkgs.config.nvidia.acceptLicense = true;
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    #"acpi_osi=" # This stops one of backlights coming up
  ];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:2:0";
    };
  };
  services.hardware.bolt.enable = true;

  services.actkbd = {
    enable = true;
    bindings = [
      # Mute
      { keys = [ 113 ]; events = [ "key" ];
        command = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      }
      # Volume down
      { keys = [ 114 ]; events = [ "key" "rep" ];
        command = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-";
      }
      # Volume up
      { keys = [ 115 ]; events = [ "key" "rep" ];
        command = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
      }
      # Mic Mute
      { keys = [ 190 ]; events = [ "key" ];
        command = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      }
      # Brightness down
      { keys = [ 224 ]; events = [ "key" "rep" ];
        command = "${pkgs.brightnessctl}/bin/brightnessctl -d intel_backlight s 10%- && ${pkgs.brightnessctl}/bin/brightnessctl -d asus_screenpad s 10%-";
      }
      # Brightness up
      { keys = [ 225 ]; events = [ "key" "rep" ];
        command = "${pkgs.brightnessctl}/bin/brightnessctl -d intel_backlight s 10%+ && ${pkgs.brightnessctl}/bin/brightnessctl -d asus_screenpad s 10%+";
      }
    ];
  };
}
