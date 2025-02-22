{inputs, ...}: final: prev: {
  cardano-submit-api-10-2-1 = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-submit-api-input-output-hk-cardano-node-10-2-1-52b708f;
  cardano-submit-api-10-1-4 = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-submit-api-input-output-hk-cardano-node-10-1-4-1f63bf;
  cardano-submit-api = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-submit-api-input-output-hk-cardano-node-10-1-3-36871ba;
}
