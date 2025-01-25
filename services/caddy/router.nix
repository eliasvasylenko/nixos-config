{
  pkgs,
  ...
}: {
  services.caddy = {
    enable = true;
    package = (pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e"
      ];
      hash = "sha256-jCcSzenewQiW897GFHF9WAcVkGaS/oUu63crJu7AyyQ=";
    });
  };
  systemd.services.caddy.serviceConfig.ProtectSystem = "strict";
}
