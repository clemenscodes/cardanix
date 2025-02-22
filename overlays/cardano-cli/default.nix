{inputs, ...}: final: prev: {
  cardano-cli-10-2-1 = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-cli-input-output-hk-cardano-node-10-2-1-52b708f;
  cardano-cli-10-1-4 = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-cli-input-output-hk-cardano-node-10-1-4-1f63bf;
  cardano-cli = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-cli-input-output-hk-cardano-node-10-1-3-36871ba;
}
