#!/bin/bash
CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $CURDIR/../config.src
export CA_ROOT=$CURDIR/../$CA_BASEDIR
export OPENSSL_CONF=$1
CERT_NAME=$(basename $OPENSSL_CONF .cnf)
openssl req -newkey rsa:4096 -keyout tempkey.pem -keyform PEM -out tempreq.pem -outform PEM
openssl rsa < tempkey.pem > server_key.pem
export OPENSSL_CONF=$CA_ROOT/ca_config.cnf
echo $OPENSSL_CONF
openssl ca -in tempreq.pem -out server_crt.pem
echo DONE
mv server_crt.pem $CERT_NAME.crt
mv server_key.pem $CERT_NAME.key
rm -f server_crt.pem server_key.pem tempkey.pem tempreq.pem
cat $CERT_NAME.crt $CERT_NAME.key > $CERT_NAME.pem
