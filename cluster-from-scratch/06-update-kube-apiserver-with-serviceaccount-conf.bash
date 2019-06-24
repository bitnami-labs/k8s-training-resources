#!/bin/bash

source ./common.bash

cat << EOF | sudo tee "$KUBE_APISERVER_SYSTEMD_SERVICE_PATH"
[Unit]
Description=kube-apiserver

[Service]
ExecStart=${KUBERNETES_BIN_DIR}/kube-apiserver \\
  --tls-cert-file=${KUBE_APISERVER_CERT_PATH} \\
  --tls-private-key-file=${KUBE_APISERVER_KEY_PATH} \\
  --client-ca-file=${KUBERNETES_CA_CERT_PATH} \\
  --etcd-cafile=${KUBERNETES_CA_CERT_PATH} \\
  --etcd-certfile=${ETCD_CLIENT_CERT_PATH} \\
  --etcd-keyfile=${ETCD_CLIENT_KEY_PATH} \\
  --etcd-servers=https://${CONTROLLER_PRIVATE_IP}:2379 \\
  --service-cluster-ip-range=${SERVICE_CLUSTERIP_NET} \\
  --authorization-mode=RBAC \\
  --v=2 \\
  --service-account-key-file=${SERVICE_ACCOUNT_GEN_CERT_PATH} \\  
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart kube-apiserver.service
systemctl restart kube-controller-manager.service

# Check now replicasets and pods

kubectl get replicasets
kubectl get pods

kubectl describe deployments nginx-test