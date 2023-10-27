{ package }:
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.playit;

  localMappingType = with types; submodule {
    options = {
      host = mkOption {
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

  localMappingsToString = tunnelUUID: localMappings:
    let
      singleLocalMappingToString = tunnelUUID: localMapping:
        let
          ipPortString =
            if (localMapping.host != null && localMapping.port != null) then "${toString localMapping.host}:${toString localMapping.port}"
            else if (localMapping.host != null && localMapping.port == null) then "${toString localMapping.host}"
            else if (localMapping.host == null && localMapping.port != null) then "${toString localMapping.port}"
            else "";
        in
        "${toString tunnelUUID}=${ipPortString}";
    in
    foldl' (acc: localMapping: acc ++ [ (singleLocalMappingToString tunnelUUID localMapping) ]) [ ] localMappings;

  maybeRunOverride =
    let
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
        default = package;
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
      after = [ "network.target" ];

      script = ''
        ${getExe cfg.package} --secret_path ${cfg.secretPath} ${maybeRunOverride}
      '';

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
      };
    };
  };
}
