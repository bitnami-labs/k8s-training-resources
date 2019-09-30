#!/bin/bash

source ./common.bash

echo "Creating etcd certificates"

mkdir -p "$ETCD_CERT_DIR"

#
# Create etcd server certificate
#
export ETCD_SERVER_CSR_PATH=/tmp/etcd_server.csr

## Private key
openssl genrsa -out "$ETCD_SERVER_KEY_PATH" 2048

export ETCD_SERVER_CERT_CONFIG=/tmp/etcd_cert_config.conf

cat <<EOF | tee ${ETCD_SERVER_CERT_CONFIG}
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_req]
subjectAltName = @alt_names
[alt_names]
DNS = ${HOSTNAME}
IP = ${CONTROLLER_PRIVATE_IP}
EOF

## Certificate sign request
openssl req -new -key "$ETCD_SERVER_KEY_PATH" -out "$ETCD_SERVER_CSR_PATH" -subj "/CN=etcd/O=etcd" -config ${ETCD_SERVER_CERT_CONFIG}
## Certificate
openssl x509 -req -in "$ETCD_SERVER_CSR_PATH" -CA "$KUBERNETES_CA_CERT_PATH" -CAkey "$KUBERNETES_CA_KEY_PATH" -CAcreateserial -out "$ETCD_SERVER_CERT_PATH"  -extensions v3_req -days 500 -extfile ${ETCD_SERVER_CERT_CONFIG}

#
# Create etcd client certificate
#
export ETCD_CLIENT_CSR_PATH=/tmp/etcd_client.csr

## Private key
openssl genrsa -out "$ETCD_CLIENT_KEY_PATH" 2048

## Certificate sign request
openssl req -new -key "$ETCD_CLIENT_KEY_PATH" -out "$ETCD_CLIENT_CSR_PATH" -subj "/CN=etcd-client/O=etcd"

## Certificate
openssl x509 -req -in "$ETCD_CLIENT_CSR_PATH" -CA "$KUBERNETES_CA_CERT_PATH" -CAkey "$KUBERNETES_CA_KEY_PATH" -CAcreateserial -out "$ETCD_CLIENT_CERT_PATH" -days 500

#
# Install etcd
#

echo "Installing etcd"

## Download and extract
wget -q "$ETCD_TARBALL_URL" -P /tmp
tar xf "/tmp/$ETCD_TARBALL_NAME" -C /tmp

## Move the binaries to the installation directory
sudo mv /tmp/etcd-v${ETCD_VERSION}-linux-amd64/etcd* "$ETCD_BIN_DIR"

## Create systemd service
cat << EOF | sudo tee $ETCD_SYSTEMD_SERVICE_PATH
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=${ETCD_BIN_DIR}/etcd \\ 
  --name ${HOSTNAME} \\
  --cert-file=${ETCD_SERVER_CERT_PATH} \\
  --key-file=${ETCD_SERVER_KEY_PATH} \\
  --trusted-ca-file=${KUBERNETES_CA_CERT_PATH} \\
  --client-cert-auth \\
  --advertise-client-urls https://${CONTROLLER_PRIVATE_IP}:2379,https://127.0.0.1:2379 \\
  --listen-client-urls https://${CONTROLLER_PRIVATE_IP}:2379,https://127.0.0.1:2379 \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd.service
systemctl restart etcd.service

# Cleanup
rm /tmp/etcd* -rf

echo "End of etcd step"
