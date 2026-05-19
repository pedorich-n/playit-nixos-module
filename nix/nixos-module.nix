{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.playit;
  defaultSocketPath = "/run/playit/playit.sock";
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

  options = {
    services.playit = {
      enable = lib.mkEnableOption "Playit Service";

      package = lib.mkPackageOption pkgs "playit" { };

      secretPath = lib.mkOption {
        type = lib.types.path;
        example = lib.literalExpression "/etc/playit/secret.toml";
        description = ''
          Path to a TOML file containing the playit agent secret.
          Loaded via systemd's `LoadCredential` directive, so the file permissions can be tightened to `0400` and owned by any user.
        '';
      };

      socketPath = lib.mkOption {
        type = lib.types.path;
        default = defaultSocketPath;
        example = lib.literalExpression "/run/playit/playit.sock";
        description = ''
          Path to the IPC socket that `playit-cli` will use to connect to `playitd`.

          ::: {.note}
          If using a non-default socket path, ensure its parent directory is accessible to the service (it is added to `ReadWritePaths` automatically).
          :::
        '';
      };

      logrotate = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          When enabled, creates a logrotate rule for playit logs.

          ::: {.note}
          You must explicitly enable `services.logrotate` for this to work.
          :::
        '';
      };

      finalPackage = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        internal = true;
        description = "Final playit package with socket path override applied if needed";
        default = if cfg.socketPath != defaultSocketPath then cfg.package.override { cliSocketPath = cfg.socketPath; } else cfg.package;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.finalPackage ];

    systemd.services.playit = {
      description = "Playit.gg agent";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = lib.concatStringsSep " " [
          (lib.getExe' cfg.finalPackage "playitd")
          "--secret-path"
          "%d/secret"
          "--log-path"
          "\"\${LOGS_DIRECTORY}/playit.log\""
          "--socket-path"
          (lib.escapeShellArg cfg.socketPath)
        ];
        Restart = "on-failure";
        LogsDirectory = "playit";
        RuntimeDirectory = "playit";
        RuntimeDirectoryMode = "0755";

        LoadCredential = [
          "secret:${cfg.secretPath}"
        ];

        # Hardening
        ReadWritePaths = [
          (dirOf cfg.socketPath)
        ];
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
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

    services.logrotate.settings = lib.mkIf cfg.logrotate {
      # Mirroring https://github.com/playit-cloud/playit-agent/blob/0ac19b418e6c97238958351b1403d9145d1aced4/linux/logrotate.conf
      playit = {
        enable = true;
        files = "/var/log/playit/playit.log";
        frequency = "daily";
        rotate = 3;
        copytruncate = true;
        compress = true;
      };
    };
  };

}
