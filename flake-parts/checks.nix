{
  self,
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      checks = {
        test-services-playit = pkgs.callPackage ../checks/service.nix { flake = self; };
      };
    };
}
