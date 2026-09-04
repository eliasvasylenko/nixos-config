{ self, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.kernelParams = [ "nomodeset" "text" ];
  boot.tmp.cleanOnBoot = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  # Root is on eMMC. generate-config put sdhci_* in availableKernelModules
  # (udev can load them) but omitted mmc_block, so the initrd never created
  # mmcblk1.
  boot.initrd.kernelModules = [ "mmc_block" ];

  environment.defaultPackages = [];
  xdg.icons.enable  = false;
  xdg.mime.enable   = false;
  xdg.sounds.enable = false;
  documentation.man.enable = false;

  # Keep stub DNS; do not take UDP 5353 from librespot.
  services.resolved = {
    enable = true;
    settings.Resolve = {
      MulticastDNS = "no";
      LLMNR = "no";
    };
  };

  imports = [
    self.inputs.disko.nixosModules.disko
    ./disk.nix
    ./hardware-configuration.nix

    ../../users/eli.nix

    ../../system/base.nix
    ../../system/networking/wired.nix

    ../../services/pulseaudio.nix
    ../../services/spotify-connect.nix
    ../../services/ssh.nix
    ../../services/tpm.nix
  ];

  # In-kernel RM (/dev/tpmrm0). abrmd exited 74 here (no usable
  # /dev/tpm0 at start); tabrmd is only required on screw-loose.
  boot.kernelModules = [ "tpm_tis" "tpm_crb" ];
  security.tpm2.abrmd.enable = false;
  security.tpm2.tctiEnvironment.interface = "device";

  system.stateVersion = "24.05"; # Did you read the comment?
}

