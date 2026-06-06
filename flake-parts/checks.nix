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
      checks = {
        test-services-playit = pkgs.callPackage ../checks/service.nix { flake = self; };
        playit-package = config.packages.playit;
      };
    };
}
