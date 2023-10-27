{ pkgs, ... }:
let
  resultFileLocation = "/etc/playit-test/result.json";
  expectedFileLocation = "/etc/playit-test/expected.json";

  package = pkgs.callPackage ./mock-playit-cli { };
  commonConfig = {
    imports = [
      (import ../nix/nixos-module.nix { inherit package; })
    ];

    environment.systemPackages = [ pkgs.diffutils ];

    systemd.tmpfiles.rules = [
      "d /etc/playit-test 0777 root root - -"
    ];
  };
in
pkgs.nixosTest {
  name = "test-services-playit";
  nodes = {
    machine1 = ({
      services.playit = {
        enable = true;
        secretPath = "/secret/path";
        runOverride = {
          "65dd196c4-5538-4633-98b2-fb26b45787b81" = [
            { port = 1234; }
            { host = "192.168.1.10"; port = 8080; }
          ];
          "9bad3ee3-e7b7-49c2-86e7-3ab5558a905a" = [
            { port = 9000; }
          ];
        };
      };
    } // commonConfig);

    machine2 = ({
      services.playit = {
        enable = true;
        secretPath = "/secret/path";
      };
    } // commonConfig);
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
