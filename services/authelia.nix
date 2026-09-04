{ pkgs, config, ... }:

{
  # Authelia
  services.authelia.instances.prod = {
    enable = false;
    settings = {
      server.address = "tcp://localhost:9091/";
      authentication_backend.ldap = {
        address = "ldap://ds.vasylenko.uk";
        implementation = "custom";
        user = "uid=auth,ou=services,dc=vasylenko,dc=uk";
        # Can we use `.path` so expand to {{- fileContent }}, and LoadCredentialEncrypted to add systemd creds stuff?
        password.path.LoadCredentialEncrypted = config.secret-agent.secrets.authelia.creds;
        base_dn = "dc=vasylenko,dc=uk";
        username_attribute = "uid";
        users_filter = "(&({username_attribute}={input})(objectClass=inetOrgPerson))";
        groups_filter = "(&(member={dn})(objectClass=groupOfNames))";
        attributes = {
          username = "uid";
          display_name = "displayName";
          mail = "mail";
          member_of = "memberOf";
          group_name = "cn";
        };
      };
      access_control = {
        rules = [
          {
            domain = "vasylenko.uk";
            policy = "one_factor";
          }
        ];
      };
      session = {
        name = "authelia_session";
        secret = "insecure_session_secret";
        expiration = "1h";
        inactivity = "5m";
        remember_me = "1M";
        same_site = "lax";
        cookies = [
          {
            domain = "vasylenko.uk";
            authelia_url = "https://login.vasylenko.uk";
          }
        ];
      };
      storage = {
        postgres = {
          address = "/var/run/postgresql/.s.PGSQL.5432";
          database = "authelia";
          username = "authelia";
          password = "test"; # TODO update
        };
      };
      notifier = {
        smtp = {
          address = "smtp://smtp.mailbox.org";
          username = "eli@mailbox.org";
          # Can we use `.path` so expand to {{- fileContent }}, and LoadCredentialEncrypted to add systemd creds stuff?
          #password = ''{{- fileContent "/var/lib/authelia/creds/mailbox-password"}}''; # TODO update
          password.path.loadEncrypted = "ref to secret-agent";
          timeout = "5s";
          disable_require_tls = false;
          sender = "Auth Notifier <login@vasylenko.uk>";
          subject = "[Auth vasylenko.uk] {title}";
        };
      };
    };
    # TODO radicle splits on :, if there is one it's encrypted, else it's not.
    secrets.jwtSecretFile.LoadCredentialEncrypted = "jwt-secret:/var/lib/authelia/creds/jwt-secret";
    secrets.storageEncryptionKeyFile.LoadCredentialEncrypted = "storage-encryption-key:/var/lib/authelia/creds/storage-encryption-key";
  };

  # Creds
  systemd.services.authelia-prod.serviceConfig = {
    BindPaths = [ "%d:/var/lib/authelia/creds" ];
    LoadCredentialEncrypted = [
      "ldap-authelia-password:/etc/credstore.encrypted/ldap-authelia-password.cred"
      "jwt-secret:/etc/credstore.encrypted/jwt-secret.cred"
      "storage-encryption-key:/etc/credstore.encrypted/storage-encryption-key.cred"
    ];
  };

  # Caddy
  services.caddy.virtualHosts."login.vasylenko.uk".extraConfig = ''
    reverse_proxy localhost:9091
  '';

  # Postgres
  services.postgresql = {
    ensureDatabases = [ "authelia" ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser   auth-method
      local authelia  authelia trust
    '';
  };
}
