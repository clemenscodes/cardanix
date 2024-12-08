{inputs, ...}: final: prev: {
  inherit
    (inputs.cardano-node.legacyPackages.${prev.stdenv.hostPlatform.system})
    bech32
    ;
}
