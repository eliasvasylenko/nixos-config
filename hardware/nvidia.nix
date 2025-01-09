{ config, pkgs, ... }:

{
  nixpkgs.config.nvidia.acceptLicense = true;
  environment.sessionVariables = rec {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    MOZ_ENABLE_WAYLAND = "1";
    WLR_RENDERER = "vulkan";
    NIXOS_OZONE_WL = "1";
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
  };
  services.xserver.videoDrivers = [ "nvidia" "modesetting" ];
  hardware.graphics = {
    enable = true;
  };
}
