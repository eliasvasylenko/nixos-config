{ ... }:

{
  users.users.eli = {
    isNormalUser = true;
    description = "Eli Vasylenko";
    extraGroups = [ "wheel" "weston_launch" ];
    packages = [];
    openssh.authorizedKeys.keys = [ "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBHwC0+tU7xhCg6KFhKoAdqT8sw74Y7KkftsduVal7o8IQh6INIJsOxfI4+vCekwa0aaWYFG6O0GIdbgnHJE+Q8Pg6QfICxP0qBmwcgv1+ZSx+1nfH+qx3gRF3qHiYb+7AQ==" ];
  };
  nix.settings.trusted-users = [ "eli" ];
  security.pam = {
    rssh.enable = true;
    rssh.settings.auth_key_file = "/etc/ssh/authorized_keys.d/eli";
    services.sudo.rssh = true;
  };
}
