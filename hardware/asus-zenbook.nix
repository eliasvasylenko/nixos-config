{ config, pkgs, ... }:

{
  imports = [
    ./nvidia.nix
  ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    acpi_call
  ];
  boot.kernelModules = [ "acpi_call" ];
  systemd.services.screenpad-backlight = {
    enable = true;
    script = ''
      echo '\_SB.ATKD.WMNB 0x0 0x53564544 b32000500FF000000' | tee /proc/acpi/call
    '';
    wantedBy = [ "multi-user.target" ];
  };
  nixpkgs.config.nvidia.acceptLicense = true;
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:2:0";
    };
  };
  powerManagement.enable = false;
  services.hardware.bolt.enable = true;
}
