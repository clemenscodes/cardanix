{
  inputs,
  system,
  ...
}: final: pkgs: {
  cardano-scripts = let
    inherit (pkgs) lib;
    createPaymentKey = import ./createPaymentKey {inherit pkgs lib;};
    createStakeKey = import ./createStakeKey {inherit pkgs lib;};
  in
    pkgs.stdenv.mkDerivation {
      name = "cardano-scripts";
      phases = "installPhase";
      nativeBuildInputs = [
        inputs.cardano-wallet.packages.${system}.cardano-cli
      ];
      installPhase = ''
        mkdir -p $out/bin
        ln -s ${createPaymentKey}/bin/create-payment-key $out/bin
        ln -s ${createStakeKey}/bin/create-stake-key $out/bin
      '';
    };
}
