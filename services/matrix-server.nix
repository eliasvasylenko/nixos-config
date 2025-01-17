{ config, lib, pkgs, hostName, ... }:

{
  # https://nixos.org/manual/nixos/stable/index.html#module-services-matrix-synapse
  
  services.matrix-synapse = {
    enable = true;
    settings.server_name = "matrix.vasylenko.uk";
    settings.public_baseurl = baseUrl;
    settings.listeners = [
      { port = 8008;
        bind_addresses = [ "::1" ];
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [ {
          names = [ "client" "federation" ];
          compress = true;
        } ];
      }
    ];
  };
}