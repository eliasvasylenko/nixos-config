{ config, pkgs, ... }:

{
  services.authelia.instances.prod = {
    enable = true;
  };
}