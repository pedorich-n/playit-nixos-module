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
        test-services-playit = pkgs.callPackage ../checks/test-services-playit.nix { flake = self; };
      };
    };
}
