{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 389 686 ];
  services.openldap = {
    enable = true;

    /* enable plain connections only */
    urlList = [ "ldap://ldap.vasylenko.uk/" ];

    settings = {
      attrs = {
        olcLogLevel = "conns config";
      };

      children = {
        "cn=schema".includes = [
          "${pkgs.openldap}/etc/schema/core.ldif"
          "${pkgs.openldap}/etc/schema/cosine.ldif"
          "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
        ];

        "olcDatabase={1}mdb".attrs = {
          objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];

          olcDatabase = "{1}mdb";
          olcDbDirectory = "/var/lib/openldap/data";

          olcSuffix = "dc=vasylenko,dc=uk";

          /* your admin account, do not use writeText on a production system */
          olcRootDN = "cn=eli-admin,dc=vasylenko,dc=uk";
          olcRootPW.path = "openldap/creds/ldap-admin-password";

          olcAccess = [
            /* custom access rules for userPassword attributes */
            ''{0}to attrs=userPassword
                by self write
                by anonymous auth
                by * none''

            /* allow read on anything else */
            ''{1}to *
                by * read''
          ];
        };
      };
    };
  };
  systemd.services.openldap.serviceConfig.BindPaths = ["%d:openldap/creds"];
  systemd.services.openldap.serviceConfig.LoadCredentialEncrypted = ["ldap-admin-password:/etc/credstore.encrypted/ldap-admin-password.cred"];
}