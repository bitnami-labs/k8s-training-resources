#!/bin/bash

#
# Online Talk part 1: User creation
#

# At the end of this script, you will have a new user in your
# minikube cluster

# We will use jsalmeron as the example user

## Create cert dirs
mkdir -p ~/.certs/kubernetes/minikube/

## Private key
openssl genrsa -out ~/.certs/kubernetes/minikube/jsalmeron.key 2048

## Certificate sign request
openssl req -new -key ~/.certs/kubernetes/minikube/jsalmeron.key -out /tmp/jsalmeron.csr -subj "/CN=jsalmeron/O=devs/O=tech-lead"

## Certificate
openssl x509 -req -in /tmp/jsalmeron.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out ~/.certs/kubernetes/minikube/jsalmeron.crt  -days 500

# Check the content of the certificate
openssl x509 -in "$HOME/.certs/kubernetes/minikube/jsalmeron.crt" -text -noout

# Add new kubectl context

# This one is not necessary
# MINIKUBE_IP=$(minikube ip)
# kubectl config set-cluster minikube --certificate-authority=$HOME/.certs/kubernetes/minikube/ca.crt --embed-certs=true --server=https://${MINIKUBE_IP}:6443

kubectl config set-credentials jsalmeron@minikube --client-certificate="$HOME/.certs/kubernetes/minikube/jsalmeron.crt" --client-key="$HOME/.certs/kubernetes/minikube/jsalmeron.key" --embed-certs=true

kubectl config set-context jsalmeron@minikube --cluster=minikube --user=jsalmeron@minikube

# Set new context
kubectl config use-context jsalmeron@minikube

# Try
kubectl get pods
