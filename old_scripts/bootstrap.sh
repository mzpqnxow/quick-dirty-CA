#!/bin/bash
CURDIR=$(dirname $BASH_SOURCE)
CA_ROOT=$CURDIR/CA
[[ -d CA/serial ]] && (echo "CA already has a serial number file.. bailing out"; /bin/false) || echo "Creating new CA ..."
cd ~/ && mkdir -p CA/signedcerts && mkdir -p CA/private && cd CA
echo '01' > serial && touch index.txt
mv ~/ca_config.cnf ~/CA/
export OPENSSL_CONF=~/CA/ca_config.cnf
openssl req -x509 -newkey rsa:4096 -out cacert.pem -outform PEM -days 1825
