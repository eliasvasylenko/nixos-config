{
  config,
  lib,
  modulesPath,
  ...
}:

let
  homeNetworks = import ../system/networking/wireless/home-networks.nix;
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../users/eli.nix
  ];

  networking.hostName = "busy-bee";
  console.keyMap = "uk";

  # Wyse 3040 and similar: eMMC sits on SDHCI and is easy to miss on a
  # minimal live image until these are loaded.
  boot.kernelModules = [
    "mmc_block"
    "sdhci"
    "sdhci_acpi"
    "sdhci_pci"
  ];

  # Ethernet: NetworkManager DHCP (stock installer).
  # Home Wi-Fi: same networks as system/networking/wireless/home.nix.
  networking.networkmanager.ensureProfiles.profiles = lib.mapAttrs (ssid: network: {
    connection = {
      id = ssid;
      type = "wifi";
      autoconnect = true;
    };
    wifi = {
      ssid = ssid;
      mode = "infrastructure";
    };
    wifi-security = {
      key-mgmt = "wpa-psk";
      psk = network.pskRaw;
    };
    ipv4.method = "auto";
    ipv6.method = "auto";
  }) homeNetworks;

  isoImage.edition = lib.mkForce "installer";
  isoImage.volumeID = "nixos-installer";

  users.users.nixos.openssh.authorizedKeys.keys =
    config.users.users.eli.openssh.authorizedKeys.keys;
  users.users.root.openssh.authorizedKeys.keys =
    config.users.users.eli.openssh.authorizedKeys.keys;

  services.getty.helpLine = lib.mkAfter ''

    SSH is enabled (ethernet DHCP, or autoconnect to home Wi-Fi).
    Log in as nixos or root with your key, then from the laptop:
      install-host <hostname> nixos@<this-host>
  '';
}
