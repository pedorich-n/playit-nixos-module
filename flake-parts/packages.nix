{
  self,
  inputs,
  ...
}:
{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      packages = {
        playit = pkgs.callPackage ../nix/package.nix { inherit (inputs) playit-agent-source; };
        default = config.packages.playit;
        docs = pkgs.callPackage ../nix/docs.nix { localFlake = self; };
        # mock = pkgs.callPackage ../test/mock-playit-cli.nix { };
      };
    };
}
