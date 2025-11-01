{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    settings = {
      #port = 37588;
    };

    ensureDatabases = [ "test" ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser   auth-method
      local sameuser  all      trust
      local all       postgres trust
    '';
  };
}
