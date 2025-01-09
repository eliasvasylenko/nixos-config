{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../users/eli.nix

    ../../system/base.nix
    ../../system/networking/wireless/roaming.nix
    ../../system/fonts.nix

    ../../services/pipewire.nix
    ../../services/tpm.nix

    ../../programs/steam.nix
    ../../programs/sway.nix
  ];

  services.xserver = {
    xkb = {
      layout = "gb";
      variant = "";
    };
  };
  console.keyMap = "uk";

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  environment.systemPackages = with pkgs; [
    alacritty
    firefox
    direnv
    prismlauncher
  ];

  services.libinput.enable = true;

  system.stateVersion = "22.11";
}
