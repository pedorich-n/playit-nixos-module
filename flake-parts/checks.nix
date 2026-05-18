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
        test-services-playit = pkgs.callPackage ../test/test-services-playit.nix { flake = self; };
      };
    };
}
