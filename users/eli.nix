{ config, pkgs, ... }:

{
  users.users.eli = {
    isNormalUser = true;
    description = "Eli Vasylenko";
    extraGroups = [ "wheel" "weston_launch" ];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [ "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBJbrxnO/GFEaCt8hdFr/ShLWHkG7rEQOcKapRIBZPt70FnbZKcQXgrgQt3fMBI6bSq1oa8hZHx8iUESgLkwXO83YJ/Y1GC+wDvVT/lluUx+Imm/mCn/DNqrcSW5IHHrI6Q==" ];
  };
  nix.settings.trusted-users = [ "eli" ];
  security.pam = {
    sshAgentAuth.enable = true;
    services.sudo.sshAgentAuth = true;
  };
}
