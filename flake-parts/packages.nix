{ inputs, ... }:
{
  perSystem =
    { config, pkgs, ... }:
    {
      packages = {
        playit-cli = pkgs.callPackage ../nix/package.nix { inherit (inputs) playit-agent-source; };
        default = config.packages.playit-cli;
        # docs = pkgs.callPackage ../nix/docs.nix { };
        # mock = pkgs.callPackage ../test/mock-playit-cli.nix { };
      };
    };
}
