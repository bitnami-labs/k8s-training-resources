#!/bin/bash

source ./common.bash

echo "Creating Helm service account"

export TILLER_SA_YAML_PATH=/tmp/tiller-sa.yaml

cat << EOF | tee $TILLER_SA_YAML_PATH
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller-sa
  namespace: kube-system
EOF

kubectl apply -f $TILLER_SA_YAML_PATH

export TILLER_CLUSTERROLEBINDING_PATH=/tmp/tiller-clusterrolebinding.yaml

cat << EOF | tee $TILLER_CLUSTERROLEBINDING_PATH
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tiller-rolebinding
subjects:
- kind: ServiceAccount
  name: tiller-sa # Name is case sensitive
  apiGroup: ""
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl apply -f $TILLER_CLUSTERROLEBINDING_PATH

# helm init --upgrade --service-account tiller-sa
helm init --service-account tiller-sa --override spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | kubectl apply -f -

# Try doing helm ls, does it work?

helm ls