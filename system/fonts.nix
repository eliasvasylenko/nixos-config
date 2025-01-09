{ config, pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      fira-code
      fira-code-symbols
      openmoji-color
      font-awesome
    ];
    fontconfig.defaultFonts = {
      emoji = [ "OpenMoji Color" ];
      monospace = [ "Fira Code" ];
    };
  };
}
