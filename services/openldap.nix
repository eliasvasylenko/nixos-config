{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [
    389
    686
  ];
  services.openldap = {
    enable = true;

    urlList = [
      "ldap:///"
      "ldaps:///"
      "ldapi:///"
    ];

    settings = {
      attrs = {
        olcLogLevel = "conns config";
      };

      children = {
        "cn=schema".includes = [
          "${pkgs.openldap}/etc/schema/core.ldif"
          "${pkgs.openldap}/etc/schema/cosine.ldif"
          "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
          "${pkgs.openldap}/etc/schema/nis.ldif"
        ];
        # "olcDatabase={-1}frontend" = {
        #   attrs = {
        #     objectClass = "olcDatabaseConfig";
        #     olcDatabase = "{-1}frontend";
        #     olcAccess = [ "{0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break" ];
        #   };
        # };
        # "olcDatabase={0}config" = {
        #   attrs = {
        #     objectClass = "olcDatabaseConfig";
        #     olcDatabase = "{0}config";
        #     olcAccess = [ "{0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break" ];
        #   };
        # };
        "olcDatabase={1}mdb".attrs = {
          objectClass = [
            "olcDatabaseConfig"
            "olcMdbConfig"
          ];

          olcDatabase = "{1}mdb";
          olcDbDirectory = "/var/lib/openldap/data";

          olcSuffix = "dc=vasylenko,dc=uk";

          olcRootDN = "cn=admin,dc=vasylenko,dc=uk";
          olcRootPW.path = "/var/lib/openldap/creds/ldap-admin-password";

          olcAccess = [
            # custom access rules for userPassword attributes
            ''
              {0}to attrs=userPassword
                by self write
                by anonymous auth
                by * none
            ''

            # allow read on anything else
            ''
              {1}to *
                by dn="cn=Elias Vasylenko,ou=users,dc=vasylenko,dc=uk" manage
                by * read
            ''
          ];
        };
      };
    };
    # mutableConfig = true;
    declarativeContents."dc=vasylenko,dc=uk" = ''
      dn: dc=vasylenko,dc=uk
      objectClass: domain
      dc: vasylenko

      dn: ou=users,dc=vasylenko,dc=uk
      objectClass: organizationalUnit
      ou: users

      dn: ou=groups,dc=vasylenko,dc=uk
      objectClass: organizationalUnit
      ou: groups

      dn: ou=services,dc=vasylenko,dc=uk
      objectClass: organizationalUnit
      ou: services

      dn: cn=Admins,ou=groups,dc=vasylenko,dc=uk
      objectClass: groupOfNames
      cn: Admins
      member: cn=Elias Vasylenko,ou=users,dc=vasylenko,dc=uk

      dn: uid=auth,ou=services,dc=vasylenko,dc=uk
      objectClass: account
      objectClass: simpleSecurityObject
      uid: auth
      userPassword: password

      dn: cn=Eli,ou=users,dc=vasylenko,dc=uk
      objectClass: inetOrgPerson
      cn: Eli
      displayName: Eli
      givenName: Elias
      sn: Vasylenko
      uid: eli
      mail: eli@vasylenko.uk
      userPassword: password

      dn: cn=Lindsey,ou=users,dc=vasylenko,dc=uk
      objectClass: inetOrgPerson
      cn: Lindsey
      displayName: Lindsey
      givenName: Lindsey
      sn: Kendall
      uid: lindsey
      mail: lindsey@vasylenko.uk
      userPassword: password
    '';
  };
  systemd.services.openldap.serviceConfig = {
    BindPaths = [ "%d:/var/lib/openldap/creds" ];
    LoadCredentialEncrypted = [
      "ldap-admin-password:/etc/credstore.encrypted/ldap-admin-password.cred"
    ];
  };
  services.caddy.virtualHosts."ds.vasylenko.uk".extraConfig = ''
    reverse_proxy localhost:389
  '';
}
