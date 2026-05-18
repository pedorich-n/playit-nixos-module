{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.playit;
in
{
  imports = [
    (lib.modules.mkRemovedOptionModule [ "services" "playit" "runOverride" ] ''
      Playit service now uses `start` instead of `run` command to run `playit-cli`.
      It's no longer possible to specify the port overrides from the agent's side.
      Please visit the repository for an updated manual on how to setup an agent and ip/port mappings.
    '')
    (lib.modules.mkRemovedOptionModule [ "services" "playit" "user" ] ''
      The `user` option has been removed. Playit service now runs under a dynamic user for better security.
    '')
    (lib.modules.mkRemovedOptionModule [ "services" "playit" "group" ] ''
      The `group` option has been removed. Playit service now runs under a dynamic group for better security.
    '')
  ];

  ###### interface
  options = {
    services.playit = {
      enable = lib.mkEnableOption "Playit Service";

      package = lib.mkPackageOption pkgs "playit" { };

      secretPath = lib.mkOption {
        type = lib.types.path;
        description = "Path to TOML file containing secret";
      };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.playit = {
      description = "Playit.gg agent";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = {
        SECRET_PATH = "%d/secret";
      };

      serviceConfig = {
        ExecStart = ''${lib.getExe' cfg.package "playitd"} --secret-path "''${SECRET_PATH}" --log-path "''${LOGS_DIRECTORY}/playit.log"'';
        Restart = "on-failure";
        StateDirectory = "playit";
        LogsDirectory = "playit";

        LoadCredential = [
          "secret:${cfg.secretPath}"
        ];

        # Hardening
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        DynamicUser = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        ProtectClock = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = [ ];
      };
    };

    # Mirroring https://github.com/playit-cloud/playit-agent/blob/0ac19b418e6c97238958351b1403d9145d1aced4/linux/logrotate.conf
    services.logrotate.settings.playit = {
      enable = true;
      files = "/var/log/playit/playit.log";
      frequency = "daily";
      rotate = 3;
      copytruncate = true;
      compress = true;
    };
  };

}
