#!/usr/bin/env bash

name=$1

if [ "$name" = "" ]; then
  echo "Usage: make-config.sh name"
  exit;
fi

KEY_DIR=~/openvpn-ca/keys
OUTPUT_DIR=~/client-configs/files
BASE_CONFIG=~/client-configs/base.conf
USER_DIR=/home/ubuntu/openvpn/${name}

rm -rf ${USER_DIR}
rm -rf ${USER_DIR}.zip

mkdir -p ${USER_DIR}

for ITEM in ${KEY_DIR}/${name}.crt ${KEY_DIR}/ca.crt ${KEY_DIR}/${name}.key ${KEY_DIR}/ta.key
do
  cp ${ITEM} ${USER_DIR}
done

cat ${BASE_CONFIG} > ${OUTPUT_DIR}/${name}.ovpn

TA_VALUE=`cat ${KEY_DIR}/ta.key`
CA_VALUE=`cat ${KEY_DIR}/ca.crt`
CERT_VALUE=`cat ${KEY_DIR}/${name}.crt`
KEY_VALUE=`cat ${KEY_DIR}/${name}.key`

echo "
<tls-auth>
${TA_VALUE}
</tls-auth>" >> ${OUTPUT_DIR}/${name}.ovpn

echo "
<ca>
${CA_VALUE}
</ca>" >> ${OUTPUT_DIR}/${name}.ovpn

echo "
<cert>
${CERT_VALUE}
</cert>" >> ${OUTPUT_DIR}/${name}.ovpn

echo "
<key>
${KEY_VALUE}
</key>" >> ${OUTPUT_DIR}/${name}.ovpn

cp ${OUTPUT_DIR}/${name}.ovpn ${USER_DIR}

cd ${USER_DIR}/../

zip -r ${name}.zip ${name}

chown ubuntu:ubuntu ${USER_DIR}
chown ubuntu:ubuntu ${USER_DIR}.zip
