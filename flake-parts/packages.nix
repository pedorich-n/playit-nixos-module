{
  self,
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
        playit = pkgs.callPackage ../nix/package.nix { };
        default = config.packages.playit;
        docs = pkgs.callPackage ../nix/docs.nix { localFlake = self; };
        # mock = pkgs.callPackage ../test/mock-playit-cli.nix { };
      };
    };
}
