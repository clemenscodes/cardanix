{
  inputs,
  home,
  pkgs,
  system,
}: let
  daedalus_ = inputs.daedalus.packages.${system}.default;
  daedalusWrapper = pkgs.writeShellScriptBin "daedalus-wrapper" ''
    XDG_DATA_HOME="''${XDG_DATA_HOME}:-${home}"
    exec ${daedalus_}/bin/daedalus
  '';
  daedalus = pkgs.stdenv.mkDerivation {
    inherit (daedalus_) name;
    phases = "installPhase";
    installPhase = ''
      mkdir -p $out/{bin,share/applications}
      cp -r ${daedalus_}/config $out/config
      cp -r ${daedalus_}/libexec $out/libexec
      cp ${desktopEntry} $out/share/applications/Daedalus-mainnet.desktop
      cp ${daedalusWrapper}/bin/daedalus-wrapper $out/bin/daedalus
    '';
  };
  desktopEntry = pkgs.writeText "Daedalus.desktop" ''
    [Desktop Entry]
    Categories=Application;Network
    Exec=${daedalus}/bin/daedalus
    GenericName=Crypto-Currency Wallet
    Icon=${daedalus_}/share/icon_large.png
    Name=Daedalus mainnet
    StartupWMClass=Daedalus Mainnet
    Type=Application
    Version=1.4
  '';
in
  daedalus
