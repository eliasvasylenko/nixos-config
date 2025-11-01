{ ... }:

{
  virtualisation.oci-containers.containers.phpldapadmin = {
    image = "leenooks/phpldapadmin:2.0.0";
    autoStart = true;
    ports = [ "6680:8080" ];
    environment = {
      APP_URL = "https://ldap.vasylenko.uk";
      LDAP_HOST = "ds.vasylenko.uk";
      LDAP_BASE_DN = "cn=root,dc=vasylenko,dc=uk";
      LDAP_LOGIN_OBJECTCLASS = "inetOrgPerson";
      LDAP_NAME = "vasylenko.uk";
    };
  };
  services.caddy.virtualHosts."ldap.vasylenko.uk".extraConfig = ''
    reverse_proxy localhost:6680
  '';
}
