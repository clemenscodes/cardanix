{inputs, ...}: final: prev: {
  inherit
    (inputs.cardano-node.packages.${prev.stdenv.hostPlatform.system})
    cardano-submit-api
    ;
}
