_: {
  perSystem = { pkgs, ... }: {
    checks = {
      test-services-playit = import ../test/test-services-playit.nix { inherit pkgs; };
    };
  };
}
