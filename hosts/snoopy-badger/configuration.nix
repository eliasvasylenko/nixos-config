{ self, ... }:

{
  imports = [
    self.inputs.disko.nixosModules.disko
    ./disk.nix
    ./hardware-configuration.nix

    ../../users/eli.nix

    ../../system/base.nix
    ../../system/networking/wired.nix

    ../../services/ssh.nix
    ../../services/tpm.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "25.11";
}
