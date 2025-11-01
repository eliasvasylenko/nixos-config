{ pkgs, ... }:
{
  services.dendrite = secrets: {
    enable = true;
    settings = {
      global = {
        server_name = "matrix.vasylenko.uk";
        private_key = "$CREDENTIALS_DIRECTORY/private_key";
      };
      client_api.registration_shared_secret = "$CREDENTIALS_DIRECTORY/registration_shared_secret";
    };
  };

  secret-agent.keys."dendrite/private_key" = {
    create = [ "${pkgs.openssl}/bin/openssl" "rand" "-base64" "32" ];
    systemd.dendrite.enable = true;
  };
  secret-agent.keys."dendrite/registration_shared_secret" = {
    create = [ "${pkgs.openssl}/bin/openssl" "rand" "-base64" "32" ];
    systemd.dendrite.enable = true;
  };
}
