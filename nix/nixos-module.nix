{ config, lib, ... }:
let
  cfg = config.services.playit;
in
{
  ###### interface
  options = {
    services.playit = {
      enable = lib.mkEnableOption "Playit Service";

      package = lib.mkOption {
        type = lib.types.package;
        description = "playit binary to run";
      };

      secretPath = lib.mkOption {
        type = lib.types.path;
        description = "Path to TOML file containing secret";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "playit";
        description = "User account under which Playit runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "playit";
        description = "Group under which Playit runs.";
      };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    users.users = lib.optionalAttrs (cfg.user == "playit") {
      playit = {
        isSystemUser = true;
        group = "playit";
        description = "Playit daemon user";
      };
    };

    users.groups = lib.optionalAttrs (cfg.group == "playit") {
      playit = { };
    };

    environment.systemPackages = [ cfg.package ];

    systemd.services.playit = {
      description = "Playit.gg agent";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "systemd-resolved.service" ];

      script = ''
        ${lib.getExe cfg.package} --stdout --secret_wait --secret_path ${cfg.secretPath} start
      '';

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        StateDirectory = "playit";

        # Hardening
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        ProtectClock = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = [ ];
      };
    };
  };
}
