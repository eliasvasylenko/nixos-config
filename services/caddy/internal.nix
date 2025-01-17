{
  pkgs,
  ...
}: {
  services.caddy.enable = true;
  systemd.services.caddy.serviceConfig.ProtectSystem = "strict";
}
