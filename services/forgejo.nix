{
  pkgs,
  config,
  lib,
  ...
}:
let
  domain = "vasylenko.uk";
in {
  services.forgejo = {
    enable = true;
    database.type = "postgres";

    settings = {
      server = {
        DOMAIN = "git.${domain}";
        SSH_DOMAIN = "git.${domain}";
        HTTP_ADDR = "localhost";
        HTTP_PORT = 3000;
        SSH_PORT = 2222;
        ROOT_URL = "https://git.vasylenko.uk/";
      };

      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 3000 ];
  networking.firewall.allowedUDPPorts = [ 3000 ];

  services.caddy.virtualHosts."git.${domain}".extraConfig = ''
    reverse_proxy localhost:3000
  '';

  services.restic.backups.forgejo = {
    user = "forgejo";
    repository = "file:/mnt/das/backups";
    passwordFile = "${pkgs.writeText "password" "12345"}"; # this is just for testing
    paths = [
      "/var/lib/forgejo/forgejo-db.sql"
      "/var/lib/forgejo/repositories/"
      "/var/lib/forgejo/data/"
      "/var/lib/forgejo/custom/"
      # Conf is backed up via nix
    ];
    backupPrepareCommand = lib.getExe (pkgs.writeShellApplication {
      name = "forgejo-backup-prepare";
      runtimeInputs = with pkgs; [ config.services.postgresql.package ];
      text = "systemctl stop forgejo && pg_dump ${config.services.forgejo.database.name} --file=/var/lib/forgejo/forgejo-db.sql";
    });
    backupCleanupCommand = lib.getExe (pkgs.writeShellApplication {
      name = "forgejo-backup-cleanup";
      runtimeInputs = [ pkgs.coreutils ];
      text = "systemctl start forgejo && rm /var/lib/forgejo/forgejo-db.sql";
    });
  };
}

