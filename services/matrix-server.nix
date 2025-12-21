{ pkgs, config, ... }:
{
  services.dendrite = secrets: {
    enable = true;
    settings = {
      global = {
        server_name = "matrix.vasylenko.uk";
        private_key = config.secret-agent.ref."dendrite/private_key";
      };
      client_api.registration_shared_secret = config.secret-agent.ref."dendrite/registration_shared_secret";
    };
  };

  secret-agent.secrets."dendrite/private_key" = {
    create = [ "${pkgs.openssl}/bin/openssl" "rand" "-base64" "32" ];
  };
  secret-agent.secrets."dendrite/registration_shared_secret" = {
    create = [ "${pkgs.openssl}/bin/openssl" "rand" "-base64" "32" ];
  };
}
