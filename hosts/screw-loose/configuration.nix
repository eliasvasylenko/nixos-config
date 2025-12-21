{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../users/eli.nix

    ../../system/base.nix
    ../../system/networking/wireless/roaming.nix
    ../../system/fonts.nix

    ../../services/pipewire.nix
    ../../services/postgres.nix
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

  environment.systemPackages = with pkgs; [
    alacritty
    firefox
    direnv
    prismlauncher
    screen
    openldap
    inetutils
    nmap
    unixtools.arp
    (pkgs.vscode-with-extensions.override {
      vscode = pkgs.vscodium;
      vscodeExtensions = with pkgs.nix-vscode-extensions.open-vsx; [
        jnoortheen.nix-ide
      ];
    })
  ];

  services.libinput.enable = true;

  system.stateVersion = "22.11";
}
