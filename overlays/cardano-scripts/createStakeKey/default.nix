{
  pkgs,
  lib,
  ...
}:
pkgs.writeShellScriptBin "create-stake-key" ''
  PUBLIC_KEY="stake.vkey"
  PRIVATE_KEY="stake.skey"
  echo "Creating take key with verification key $PUBLIC_KEY and signing key $PRIVATE_KEY"
  ${lib.getExe pkgs.cardano-cli} \
    latest \
    stake-address \
    key-gen \
    --verification-key-file $PUBLIC_KEY \
    --signing-key-file $PRIVATE_KEY
''
