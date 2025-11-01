{ ... }:
{
  imports = [
    ../modules/secret-agent.nix
  ];

  programs.secret-agent.enable = true;
}