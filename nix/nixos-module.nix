{ package }:
{ config, lib, ... }:
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

      package = lib.mkOption {
        type = lib.types.package;
        default = package;
        description = "playit binary to run";
      };

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

      script = ''
        ${lib.getExe cfg.package} --stdout --secret_wait --secret_path "''${SECRET_PATH}" start
      '';

      environment = {
        SECRET_PATH = "%d/secret";
      };

      serviceConfig = {
        Restart = "on-failure";
        StateDirectory = "playit";

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
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        ProtectClock = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = [ ];
        ProtectSystem = "strict";
        ProtectHome = "read-only";
      };
    };
  };
}
