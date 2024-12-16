{inputs, ...}: final: prev: {
  cardano-submit-api = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-submit-api-input-output-hk-cardano-node-10-1-3-36871ba;
}
