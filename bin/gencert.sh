#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
: ${SAN:=127.0.0.1}
: ${CERTNAME:=failed}
: ${PASSPHRASE:=foo}
: ${PASSPHRASE:=MyOrg}
rm -f etcd-ca-depot/${CERTNAME}.host.crt
rm -f etcd-ca-depot/${CERTNAME}.host.csr
rm -f etcd-ca-depot/${CERTNAME}.host.key
rm -f tmp/${CERTNAME}.key.insecure
/usr/local/bin/etcd-ca --depot-path etcd-ca-depot new-cert \
	--ip ${SAN} \
	--passphrase ${PASSPHRASE} \
       	--organization "${ORGANIZATION}" \
	${CERTNAME}
/usr/local/bin/etcd-ca --depot-path etcd-ca-depot sign \
	--passphrase ${PASSPHRASE} \
       	${CERTNAME}
/usr/local/bin/etcd-ca --depot-path etcd-ca-depot export \
	--insecure --passphrase ${PASSPHRASE} ${CERTNAME} |tar xfq - ${CERTNAME}.key.insecure; cat ${CERTNAME}.key.insecure > tmp/${CERTNAME}.key.insecure; rm ${CERTNAME}.key.insecure
