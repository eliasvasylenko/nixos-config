{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.secret-agent;
  serviceOptions = name: {
    enable = mkEnableOption "credential";

    transform = mkOption {
      description = ''
        Command to map the generated key.
      '';
      default = null;
      type = with types; nullOr str;
    };

    suppressUnencrypted = mkOption {
      description = ''
        Suppress existing unencrypted LoadCredential options.
        This is sometimes needed in case of collision.
      '';
      default = false;
      type = with types; bool;
    };

    name = mkOption {
      description = ''
        The name of the credential when encrypted with systemd-creds.
      '';
      default = name;
      type = with types; str;
    };

    bindPath = mkOption {
      description = ''
        Path to mount the credential file privately to the service.
        This is sometimes needed if the secret path is configured in a
        context where we can't expand env vars or systemd specifiers.
      '';
      default = null;
      type = with types; nullOr str;
    };
  };

  keyOptions = name: {
    generate = mkOption {
      description = ''
        Command to generate the key.
      '';
      type = with types; listOf str;
    };

    systemd = mkOption {
      description = ''
        Systemd services which will use the key.
      '';
      default = { };
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = serviceOptions name;
          }
        )
      );
    };
  };

  keyPairOptions = name: {
    public = mkOption {
      description = ''
        Services which will use the private key.
      '';
      type = types.attrsOf (
        types.submodule {
          options = keyOptions name;
        }
      );
    };
    private = mkOption {
      description = ''
        Services which will use the public key.
      '';
      type = types.submodule {
        options = keyOptions name;
      };
    };
  };
in
{
  options = {
    programs.secret-agent = {
      enable = mkEnableOption "secret agent";
    };
    secret-agent.keys = mkOption {
      description = ''
        Secret keys.
      '';
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = keyOptions name;
          }
        )
      );
      default = { };
    };
    secret-agent.keyPairs = mkOption {
      description = ''
        Secrets key pairs.
      '';
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = keyPairOptions name;
          }
        )
      );
      default = { };
    };
  };

  secret = 
  {
    name = "db-creds";
    create = "openssl rand -base64 32";
    plans = [
      {
        name = "service";
        create = "cat > /etc/enrypted-creds/$NAME/$ID.cred";
        destroy = "rm -f /etc/enrypted-creds/$NAME/$ID.cred";
        activate = "cp -f /etc/enrypted-creds/$NAME/$ID.cred /etc/enrypted-creds/service.cred";
        deactivate = "rm -f /etc/enrypted-creds/service.cred";
      }
      {
        name = "remote";
        create = "ssh host -csecret-agent create $NAME $ID";
        destroy = "ssh host -csecret-agent destroy $NAME $ID";
        activate = "ssh host -csecret-agent activate $NAME $ID";
        deactivate = "ssh host -csecret-agent deactivate $NAME $ID";
        test = "ssh host -csecret-agent test $NAME $ID";
      }
    ];
  };

  config =
    let
      configFile = pkgs.writeText "secret-agent-config.json" (builtins.toJSON cfg);
    in
    {
      systemd.services =
        (attrsets.concatMapAttrs (
          key: keyCfg:
          attrsets.concatMapAttrs (service: serviceCfg: {
            "${service}".serviceConfig = mkIf serviceCfg.enable {
              # Mount the decrypted credential on the bind path
              BindPaths = mkIf (serviceCfg.bindPath != null) [
                "%d/${serviceCfg.name}:${serviceCfg.bindPath}${
                  if (builtins.match "$.*/^" serviceCfg.bindPath) != null then serviceCfg.name else ""
                }"
              ];
              # Load the encrypted credential
              LoadCredentialEncrypted = [
                "${serviceCfg.name}:/etc/credstore.encrypted/secret-agent/${serviceCfg.name}.cred"
              ];
              # Suppress unencrypted credentials
              LoadCredential = mkIf (serviceCfg.suppressUnencrypted) (mkForce [ ]);
            };
          }) keyCfg.systemd
        ) cfg.keys)
        // {
          "secret-agent@" = {
            enable = true;
            description = "Secret agent service";
            path = with pkgs; [
              bash
              jq
              coreutils
            ];
            environment = {
              SECRET_AGENT_CONFIG = configFile;
            };
            serviceConfig = {
              Type = "simple";
              Restart = "no";
              ExecStart = ./secret-agent.sh;
              StandardInput = "socket";
              StandardOutput = "socket";
              StandardError = "journal";
            };
            requires = [ "secret-agent.socket" ];
            after = [ "secret-agent.socket" ];
          };
        };

      systemd.sockets.secret-agent = {
        enable = true;
        wantedBy = [ "sockets.target" ];
        description = "Socket to communicate with secret agent";
        listenStreams = [ "/tmp/secret-agent.socket" ];
        socketConfig = {
          Accept = "yes";
        };
      };

      # users.groups.secret-agent = { };
      # users.users.secret-agent = {
      #   isSystemUser = true;
      #   description = "Secret Agent";
      #   group = "secret-agent";
      #   extraGroups = [ "secret-agent" ];
      #   packages = [ ];
      #   openssh.authorizedKeys.keys = [
      #     "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBJbrxnO/GFEaCt8hdFr/ShLWHkG7rEQOcKapRIBZPt70FnbZKcQXgrgQt3fMBI6bSq1oa8hZHx8iUESgLkwXO83YJ/Y1GC+wDvVT/lluUx+Imm/mCn/DNqrcSW5IHHrI6Q=="
      #   ];
      # };
    };
}
