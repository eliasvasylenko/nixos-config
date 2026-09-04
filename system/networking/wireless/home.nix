{ ... }:
{
  networking = {
    firewall.enable = true;
    wireless = {
      enable = true;
      userControlled = false;
      networks = import ./home-networks.nix;
    };
    useDHCP = true;
    useNetworkd = true;
  };
}
