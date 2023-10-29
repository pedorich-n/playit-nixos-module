{ pkgs, lib, ... }:
let
  resultFileLocation = "/var/lib/playit/result.json";
  expectedFileLocation = "/var/lib/playit/expected.json";

  commonConfig = {
    imports = [ ../nix/nixos-module.nix ];
    services.playit.package = pkgs.callPackage ./mock-playit-cli { };

    environment.systemPackages = [ pkgs.diffutils ];
  };

  withCommonConfig = config: lib.attrsets.recursiveUpdate config commonConfig;
in
pkgs.nixosTest {
  name = "test-services-playit";
  nodes = {
    machine1 = withCommonConfig {
      services.playit = {
        enable = true;
        secretPath = "/secret/path";
        runOverride = {
          "65dd196c4-5538-4633-98b2-fb26b45787b81" = [
            { port = 1234; }
            { ip = "192.168.1.10"; port = 8080; }
          ];
          "9bad3ee3-e7b7-49c2-86e7-3ab5558a905a" = [
            { port = 9000; }
          ];
        };
      };
    };


    machine2 = withCommonConfig {
      services.playit = {
        enable = true;
        secretPath = "/secret/path";
      };
    };
  };

  testScript = ''
    start_all()

    with subtest("multiple-overrides"):
      machine1.wait_for_unit("playit.service")

      machine1.systemctl("status playit.service")

      machine1.copy_from_host("${./snapshots/multiple-overrides.json}", "${expectedFileLocation}")
      machine1.succeed("diff ${expectedFileLocation} ${resultFileLocation}")

      machine1.shutdown()

    with subtest("no-overrides"):
      machine2.wait_for_unit("playit.service")

      machine2.systemctl("status playit.service")

      machine2.copy_from_host("${./snapshots/no-overrides.json}", "${expectedFileLocation}")
      machine2.succeed("diff ${expectedFileLocation} ${resultFileLocation}")

      machine2.shutdown()
  '';
}
