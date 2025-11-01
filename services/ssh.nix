{ ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowAgentForwarding = "yes";
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];
}
