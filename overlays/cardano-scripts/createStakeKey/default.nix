{
  pkgs,
  lib,
  ...
}:
pkgs.writeShellScriptBin "create-stake-key" ''
  VKEY="stake.vkey"
  SKEY="stake.skey"
  echo "Creating take key with verification key $VKEY and signing key $SKEY"
  ${lib.getExe pkgs.cardano-cli} \
    latest \
    stake-address \
    key-gen \
    --verification-key-file $VKEY \
    --signing-key-file $SKEY
''
