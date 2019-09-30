#!/bin/bash

#
# Online Talk part 3: Playing with helm
#

# At the end of this script, you will experience some issues with Helm and then have it configured for your minikube cluster

## NOTE: if you want to reproduce the same environment, execute these previous commands
# kubectl config use-context minikube
# kubectl delete clusterrolebinding minikube-rbac
# Set up helm using the last set of commands

## Try deploying a dokuwiki chart
kubectl config use-context jsalmeron@minikube
helm install stable/dokuwiki --namespace=test

## We need to grant some extra permissions for jsalmeron to access tiller
kubectl config use-context minikube
kubectl apply -f ./yaml/07-helm-tiller-access.yaml
kubectl apply -f ./yaml/08-salme-use-tiller.yaml

## Try now
kubectl config use-context jsalmeron@minikube
helm ls
helm install stable/dokuwiki --namespace=test
kubectl get pods -n test -w

helm install stable/dokuwiki
kubectl run --image=bitnami/dokuwiki dokuwiki
kubectl get pods
helm install stable/dokuwiki --namespace=kube-system

## Let's delete tiller
kubectl config use-context minikube
helm reset --force
helm init --override spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | kubectl apply -f -

## Let's try now
helm ls
kubectl config use-context jsalmeron@minikube
helm install stable/dokuwiki

## Let's fix this
kubectl config use-context minikube
kubectl create serviceaccount tiller-sa -n kube-system
kubectl apply -f yaml/09-tiller-clusterrolebinding.yaml

## Redeploy helm
helm init --service-account tiller-sa --override spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | kubectl apply -f -
