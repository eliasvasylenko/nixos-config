{ config, pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraOptions = [
      "--unsupported-gpu"
    ];
    extraPackages = with pkgs; [
      xdg-utils
      wl-clipboard
      adwaita-icon-theme
      waybar
      mako
      fuzzel
      wofi
      vulkan-validation-layers
    ];
  };
  programs.xwayland.enable = true;

  environment.sessionVariables = rec {
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
  };
}
