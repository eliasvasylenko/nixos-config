{ pkgs, self, ... }:
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

    ../../programs/ssh-tpm-agent.nix
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

  nixpkgs.overlays = [ self.inputs.nix-vscode-extensions.overlays.default ];

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
    nil
    nixfmt
    (pkgs.vscode-with-extensions.override {
      # helpers/node is a non-PIE Node binary. patchelf leaves .dynamic inside a
      # read-only LOAD segment, so ld-linux segfaults and the canvas service dies.
      # Replace it with Nix's Node 24. This Cursor release ships Node 24.
      vscode = pkgs.code-cursor.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          helper="$out/lib/cursor/resources/app/resources/helpers/node"
          if [[ ! -f $helper ]]; then
            echo "cursor node helper missing at $helper" >&2
            exit 1
          fi
          rm -f "$helper"
          printf '%s\n' '#!${pkgs.runtimeShell}' 'exec ${pkgs.nodejs_24}/bin/node "$@"' > "$helper"
          chmod +x "$helper"
        '';
      });
      vscodeExtensions = with pkgs.nix-vscode-extensions.open-vsx; [
        jnoortheen.nix-ide
        golang.go
      ];
    })
  ];

  # Receive mDNS so Spotify can see Connect receivers on the LAN.
  networking.firewall.allowedUDPPorts = [ 5353 ];

  services.libinput.enable = true;

  system.stateVersion = "22.11";
}
