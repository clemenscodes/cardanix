{inputs, ...}: {
  system,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cardano;
  daedalus_ = inputs.daedalus.packages.${system}.default;
  daedalusWrapper = pkgs.writeShellScriptBin "daedalus-wrapper" ''
    if [ -z "${config.cardano.daedalus.home}" ]; then
      XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
    fi
    XDG_DATA_HOME="${config.cardano.daedalus.home}"
    exec ${daedalus_}/bin/daedalus
  '';
  daedalus = pkgs.stdenv.mkDerivation {
    inherit (daedalus_) name;
    phases = "installPhase";
    installPhase = ''
      mkdir -p $out/{bin}
      cp -r ${daedalus_}/config $out/config
      cp -r ${daedalus_}/libexec $out/libexec
      cp -r ${daedalus_}/share $out/share
      cp -r ${daedalusWrapper}/bin/daedalus-wrapper $out/bin/daedalus
    '';
  };
in {
  options = {
    cardano = {
      daedalus = {
        enable = lib.mkEnableOption "Enable daedalus" // {default = false;};
        home = lib.mkOption {
          type = lib.types.path;
          default = "";
        };
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.daedalus.enable) {
    environment = {
      systemPackages = [daedalus];
    };
  };
}
