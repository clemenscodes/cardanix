{
  pkgs,
  lib,
  ...
}:
pkgs.writeShellScriptBin "create-payment-key" ''
  VKEY="payment.vkey"
  SKEY="payment.skey"
  echo "Creating payment key with verification key $VKEY and signing key $SKEY"
  ${lib.getExe pkgs.cardano-cli} \
    latest \
    address \
    key-gen \
    --verification-key-file $VKEY \
    --signing-key-file $SKEY
''
