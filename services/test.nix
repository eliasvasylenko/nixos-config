{ config, pkgs, ... }:

{
  systemd.services.testy = {
    description = "Testy Server Daemon";
    documentation = [
      "man:slapd"
      "man:slapd-config"
      "man:slapd-mdb"
    ];
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      User = "testy";
      Group = "testy";
      ExecStartPre = [
        "!${pkgs.coreutils}/bin/mkdir -p ${configDir}"
        "+${pkgs.coreutils}/bin/chown $USER ${configDir}"
      ] ++ (lib.optional (cfg.configDir == null) writeConfig)
      ++ (mapAttrsToList (dn: content: lib.escapeShellArgs [
        writeContents dn (getAttr dn dbSettings).olcDbDirectory content
      ]) contentsFiles)
      ++ [ "${testy}/bin/slaptest -u -F ${configDir}" ];
      ExecStart = lib.escapeShellArgs ([
        "${testy}/libexec/slapd" "-d" "0" "-F" configDir "-h" (lib.concatStringsSep " " cfg.urlList)
      ]);
      Type = "notify";
      # Fixes an error where testy attempts to notify from a thread
      # outside the main process:
      #   Got notification message from PID 6378, but reception only permitted for main PID 6377
      NotifyAccess = "all";
      RuntimeDirectory = "testy";
      StateDirectory = ["testy"]
        ++ (map ({olcDbDirectory, ... }: removePrefix "/var/lib/" olcDbDirectory) (attrValues dbSettings));
      StateDirectoryMode = "700";
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    };
  };

  users.user.testy = {
    group = cfg.group;
    isSystemUser = true;
  };

  users.group.testy = {};
}