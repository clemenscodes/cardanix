{inputs, ...}: final: prev: {
  inherit
    (inputs.cardano-wallet.packages.${prev.stdenv.hostPlatform.system})
    bech32
    ;
}
