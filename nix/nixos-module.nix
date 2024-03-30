{ config, lib, ... }:
with lib;
let
  cfg = config.services.playit;

  localMappingType = with types; submodule {
    options = {
      ip = mkOption {
        type = nullOr str;
        description = "Local IP to route traffic to";
        default = null;
      };
      port = mkOption {
        type = nullOr port;
        description = "Local port to route traffic to";
        default = null;
      };
    };
  };

  maybeRunOverride =
    let
      ipPortString = { ip, port }:
        if (ip == null && port == null) then throw "IP and Port can't both be empty!"
        else concatStringsSep ":" (filter (x: x != null && x != "") [ ip (toString port) ]);

      maybeOverridesList = lists.optionals (cfg.runOverride != { }) (attrsets.foldlAttrs
        (acc: tunnelUUID: localMapping: acc ++ [ "${tunnelUUID}=${ipPortString localMapping}" ]) [ ]
        cfg.runOverride);
    in
    strings.optionalString (maybeOverridesList != [ ]) ''run ${concatStringsSep "," maybeOverridesList}'';
in
{
  ###### interface
  options = {
    services.playit = {
      enable = mkEnableOption "Playit Service";

      package = mkOption {
        type = types.package;
        description = "Playit binary to run";
      };

      runOverride = mkOption {
        type = with types; attrsOf localMappingType;
        description = "Attrset of local overrides. Name should be tunnel's UUID.";
        default = { };
        example = literalExpression ''
          runOverride = {
            "890e3610-26cd-4e2b-b161-7cf0e4f69148".port = 8080;
            "177485db-47aa-4fa9-9ccf-411ab761b9f0" = { ip = 192.168.1.1; port = 9000; };
          };
        '';
      };

      secretPath = mkOption {
        type = types.path;
        description = "Path to TOML file containing secret";
      };

      user = mkOption {
        type = types.str;
        default = "playit";
        description = "User account under which Playit runs.";
      };

      group = mkOption {
        type = types.str;
        default = "playit";
        description = "Group under which Playit runs.";
      };
    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    users.users = optionalAttrs (cfg.user == "playit") {
      playit = {
        isSystemUser = true;
        group = "playit";
        description = "Playit daemon user";
      };
    };

    users.groups = optionalAttrs (cfg.group == "playit") {
      playit = { };
    };

    environment.systemPackages = [ cfg.package ];

    systemd.services.playit = {
      description = "Playit.gg agent";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "systemd-resolved.service" ];

      script = ''
        ${getExe cfg.package} --secret_wait --secret_path ${cfg.secretPath} ${maybeRunOverride}
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
