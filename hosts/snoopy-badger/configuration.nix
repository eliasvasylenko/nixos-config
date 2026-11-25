{ self, pkgs, ... }:

{
  imports = [
    self.inputs.disko.nixosModules.disko
    ./disk.nix
    ./hardware-configuration.nix

    ../../users/eli.nix

    ../../system/base.nix
    ../../system/networking/wired.nix

    ../../services/frigate.nix
    ../../services/ssh.nix
    ../../services/tpm.nix
  ];

  # N200 iGPU: VA-API (iHD) + OpenVINO GPU.
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };
  boot.kernelModules = [ "i915" ];
  boot.kernelParams = [ "i915.enable_guc=3" ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "25.11";
}
