{ pkgs, ... }:
let
  secretValue = "XX_very_secret_value_XX";

  commonConfig =
    { pkgs, lib, ... }:
    {
      imports = [
        (lib.modules.importApply ../nix/nixos-module.nix { package = pkgs.callPackage ./mock-playit-cli.nix { }; })
      ];

      environment = {
        systemPackages = [ pkgs.curl ];
        etc."secret/path" = {
          user = "nobody";
          group = "nogroup";
          mode = "0400";
          text = secretValue;
        };
      };
    };

  withCommonConfig = config: {
    imports = [
      commonConfig
      config
    ];
  };
in
pkgs.testers.nixosTest {
  name = "test-services-playit";
  nodes = {
    machine1 = withCommonConfig {
      services.playit = {
        enable = true;
        secretPath = "/etc/secret/path";
      };
    };
  };

  testScript = ''
    start_all()

    with subtest("secret reader"):
      machine1.wait_for_unit("network-online.target")

      machine1.wait_for_unit("playit.service")
      _, out = machine1.execute("journalctl --unit playit.service --output cat --no-pager --grep 'Secret value:' | tail -n1")
      secret_log = out.strip()
      assert secret_log == "Secret value: ${secretValue}", f"Expected secret value not found in logs, got: {secret_log}"

    with subtest("running"):
      machine1.wait_for_unit("network-online.target")

      machine1.wait_for_unit("playit.service")
      machine1.wait_for_open_port(9213)
      machine1.wait_until_succeeds("curl -I http://localhost:9213 | grep '200 OK'")

      machine1.shutdown()
  '';
}
