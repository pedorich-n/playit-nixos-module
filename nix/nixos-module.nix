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
      ipPortString = localMapping:
        if (localMapping.ip != null && localMapping.port != null) then "${toString localMapping.ip}:${toString localMapping.port}"
        else if (localMapping.ip != null && localMapping.port == null) then "${toString localMapping.ip}"
        else if (localMapping.ip == null && localMapping.port != null) then "${toString localMapping.port}"
        else throw "IP and Port can't both be empty!";

      localMappingsToString = tunnelUUID: localMappings:
        foldl' (acc: localMapping: acc ++ [ "${toString tunnelUUID}=${ipPortString localMapping}" ]) [ ] localMappings;

      maybeOverridesList = lists.optionals (cfg.runOverride != { }) (attrsets.foldlAttrs
        (acc: tunnelUUID: localMappings: acc ++ (localMappingsToString tunnelUUID localMappings)) [ ]
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
        type = with types; attrsOf (listOf localMappingType);
        description = "Attrset of local overrides. Name should be tunnel's UUID";
        default = { };
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
      description = "Playit Agent";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "systemd-resolved.service" ];

      script = ''
        ${getExe cfg.package} --secret_wait --secret_path ${cfg.secretPath} ${maybeRunOverride}
      '';

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
      };
    };
  };
}
