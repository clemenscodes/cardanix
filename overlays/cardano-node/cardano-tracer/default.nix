{inputs, ...}: final: prev: {
  cardano-tracer-10-2-1 = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-tracer-input-output-hk-cardano-node-10-2-1-52b708f;
  cardano-tracer-10-1-4 = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-tracer-input-output-hk-cardano-node-10-1-4-1f63bf;
  cardano-tracer = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-tracer-input-output-hk-cardano-node-10-1-3-36871ba;
}
