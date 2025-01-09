{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.kernelParams = [ "nomodeset" "text" ];
  boot.tmp.cleanOnBoot = true;

  imports = [
    ./hardware-configuration.nix

    ../../users/eli.nix

    ../../system/base.nix
    ../../system/networking/wireless/home.nix

    ../../services/pulseaudio.nix
    ../../services/spotify-connect.nix
    ../../services/ssh.nix
    ../../services/tpm.nix
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}

