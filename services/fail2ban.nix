{ config, pkgs, ... }:

{
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "10.0.0.0/8" "172.16.0.0/12" "192.168.10.0/16"
    ];
    bantime = "5m";
    bantime-increment = {
      enable = true;
      factor = "1";
      formula = "ban.Time * (1<<(ban.Count if ban.Count<20 else 20)) * banFactor";
      maxtime = "168h";
      overalljails = true;
    };
  };
}
