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
        playit = pkgs.callPackage ../packages/playit.nix { };
        default = config.packages.playit;
        module-docs = pkgs.callPackage ../packages/module-docs.nix { localFlake = self; };
      };
    };
}
