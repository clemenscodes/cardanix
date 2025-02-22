{inputs, ...}: final: prev: {
  orchestrator-cli = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.orchestrator-cli-IntersectMBO-credential-manager-0-1-2-0-081cc8c;
}
