{ lib, config, pkgs, ... }:

{
  services.step-ca = {
    enable = true;
    address = "localhost";
    port = 7443;
    openFirewall = true;
    settings = {
      root = "/etc/step-ca/certs/root_ca.crt";
      federatedRoots = null;
      crt = "/etc/step-ca/certs/intermediate_ca.crt";
      key = "/etc/step-ca/secrets/intermediate_ca_key";
      insecureAddress = "";
      dnsNames = [
        "ca.vasylenko.uk"
        "localhost"
      ];
      logger = {
        format = "text";
      };
      db = {
        type = "badgerv2";
        dataSource = "/var/lib/step-ca/db";
        badgerFileLoadingMode = "";
      };
      authority = {
        provisioners = [
          {
            type = "JWK";
            name = "eli@vasylenko.uk";
            key = {
              use = "sig";
              kty = "EC";
              kid = "sr6a0BsLYJ3vvPyALo8_bZR2dF3UTkvDM2Tm89M2oWQ";
              crv = "P-256";
              alg = "ES256";
              x = "Ybn9vC_j_vJDQT4fHvJSyPYiedvliTOmfhtDHcmnK2A";
              y = "aEPhFNR8ISk-ecEKoFKidt2a8LBRmJpDAUTMcsyuuvc";
            };
            encryptedKey = "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjYwMDAwMCwicDJzIjoiS3dCc1dPZmtaZFRuaHJLTER3R3JaZyJ9.oPt_VOmLvAyVKNpvkOVMn0EOe33Vh25CgIMgJEQxm_YboLH3vqN6-Q._fYYEtFv-daGJ-v9.DuRLo2iwDYo0ps5jplZPTTkwZWdS2vpCzJcvuqiMWSwr5m8kBgDvpTop5jK8cdOb4m0MqMscL1CUkHOGyYPkOLZtVFHjrk-m91OlaFi7COwiSpJQGgtmv2fVVhrhqSq5owf8K88CCWpJvl6JHFoAgcf-1mnsxz96oZRq6rszeeRbhXYKhZcYmq5DMSSI0_mg8EokTOmBwoXWWcWW3l0tUf2DWDCZ9d2MbYtDZSW9fOYuDth0EQ9W2Jx9Ht4d19501bczJ1BGSCtkkXlgPco5HrpLZ2m2cf-M1kUP5b23OAyqZeHbemVTk3lltufjKbVUMj2q9kH2PW2YMyZxQo8.sipUAm0zpO6hALYyCkqULQ";
            claims = {
              enableSSHCA = true;
            };
          }
          {
            type = "SSHPOP";
            name = "sshpop";
            claims = {
              enableSSHCA = true;
            };
          }
        ];
      };
      tls = {
        cipherSuites = [
          "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
          "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        ];
        minVersion = 1.2;
        maxVersion = 1.3;
        renegotiation = false;
      };
      templates = {
        ssh = {
          user = [
            {
              name = "config.tpl";
              type = "snippet";
              template = "templates/ssh/config.tpl";
              path = "~/.ssh/config";
              comment = "#";
            }
            {
              name = "step_includes.tpl";
              type = "prepend-line";
              template = "templates/ssh/step_includes.tpl";
              path = "\${STEPPATH}/ssh/includes";
              comment = "#";
            }
            {
              name = "step_config.tpl";
              type = "file";
              template = "templates/ssh/step_config.tpl";
              path = "ssh/config";
              comment = "#";
            }
            {
              name = "known_hosts.tpl";
              type = "file";
              template = "templates/ssh/known_hosts.tpl";
              path = "ssh/known_hosts";
              comment = "#";
            }
          ];
          host = [
            {
              name = "sshd_config.tpl";
              type = "snippet";
              template = "templates/ssh/sshd_config.tpl";
              path = "/etc/ssh/sshd_config";
              comment = "#";
              requires = [
                "Certificate"
                "Key"
              ];
            }
            {
              name = "ca.tpl";
              type = "snippet";
              template = "templates/ssh/ca.tpl";
              path = "/etc/ssh/ca.pub";
              comment = "#";
            }
          ];
        };
      };
    };

    # We override the behaviour which uses this setting, but the service still expects it
    intermediatePasswordFile = "/dummy";
  };
  # This replaces the intermediatePasswordFile with an encrypted version
  systemd.services.step-ca.serviceConfig.LoadCredential = lib.mkForce null;
  systemd.services.step-ca.serviceConfig.LoadCredentialEncrypted = [
    "intermediate_password:/etc/credstore.encrypted/ca-intermediate-password.cred"
  ];
  services.caddy.virtualHosts."ca.vasylenko.uk".extraConfig = ''
    tls internal
    reverse_proxy = localhost:7443
  '';
}