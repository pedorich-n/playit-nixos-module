{ pkgs, ... }:
let
  commonConfig =
    { pkgs, ... }:
    {
      imports = [ ../nix/nixos-module.nix ];
      services.playit.package = pkgs.callPackage ./mock-playit-cli.nix { };

      environment.systemPackages = [ pkgs.curl ];
    };

  withCommonConfig = config: {
    imports = [
      commonConfig
      config
    ];
  };
in
pkgs.nixosTest {
  name = "test-services-playit";
  nodes = {
    machine1 = withCommonConfig {
      services.playit = {
        enable = true;
        secretPath = "/secret/path";
      };
    };
  };

  testScript = ''
    start_all()

    with subtest("running"):
      machine1.wait_for_unit("network.target")

      machine1.wait_for_unit("playit.service")
      machine1.wait_for_open_port(9213)
      machine1.wait_until_succeeds("curl -I http://localhost:9213 | grep '200 OK'")

      machine1.shutdown()
  '';
}
