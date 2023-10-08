inputs: {
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.configuradorfnmt;
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  options.programs.configuradorfnmt = {
    enable = mkEnableOption "configuradorfnmt";
    package = mkPackageOptionMD inputs.self.packages.${system} "configuradorfnmt" {};
    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      default = cfg.package;
      defaultText =
        literalExpression
        "`programs.configuradorfnmt.package` with applied configuration";
      description = mdDoc ''
        The configuradorfnmt package after applying configuration.
      '';
    };

    firefoxIntegration.profiles = mkOption {
      type = types.attrsOf (types.submodule ({
        config,
        name,
        ...
      }: {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
            description = "Profile name.";
          };

          enable = mkEnableOption "Enable configuradorfnmt in this firefox profile.";
        };
      }));
    };
  };
  config = mkIf cfg.enable {
    home.packages = [cfg.finalPackage];
    programs.firefox.profiles = flip mapAttrs cfg.firefoxIntegration.profiles (name: {enable, ...}: {
      settings = mkIf enable {
        "network.protocol-handler.app.fnmtcr" = "${cfg.finalPackage}/bin/configuradorfnmt";
        "network.protocol-handler.warn-external.fnmtcr" = false;
        "network.protocol-handler.external.fnmtcr" = true;
      };
    });
  };
}
