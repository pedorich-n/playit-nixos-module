{ withSystem, ... }:
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.playit;
  defaultUser = "playit";
  defaultPackage = withSystem ({ config, ... }: config.packages.playit-cli); 

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

  localMappingToString = tunnelUUID: localMapping:
    let
      ipPortString =
        if (localMapping.ip != null && localMapping.port != null) then "${toString localMapping.ip}:${toString localMapping.port}"
        else if (localMapping.ip != null && localMapping.port == null) then "${toString localMapping.ip}"
        else if (localMapping.ip == null && localMapping.port != null) then "${toString localMapping.port}"
        else "";
    in
    "${toString tunnelUUID}=${ipPortString}";

  maybeRunOverride =
    let
      maybeOverridesList = lists.optionals (cfg.runOverride != { }) (attrsets.foldlAttrs
        (acc: tunnelUUID: localMapping: acc ++ [ (localMappingToString tunnelUUID localMapping) ]) [ ]
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
        default = defaultPackage;
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
        default = defaultUser;
      };

      group = mkOption {
        type = types.str;
        default = defaultUser;
      };
    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    users.users = optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = optionalAttrs (cfg.group == defaultUser) {
      ${defaultUser} = { };
    };

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
