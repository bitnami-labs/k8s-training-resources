#!/bin/bash

#
# Online Talk part 2: Setting RBAC rules
#

# At the end of this script, you will create some access rules for your newly created user

## Switch to admin
kubectl config use-context minikube

## Create a namespace for the new user

kubectl create ns test

## Give the user privileges to see pods in the "test" namespace

kubectl apply -f ./yaml/01-pod-access-role.yaml
kubectl apply -f ./yaml/03-devs-read-pods.yaml

## Switch to the new user and try executing these commands now

kubectl config use-context jsalmeron@minikube
kubectl get pods
kubectl get pods -n test
kubectl run -n test nginx --image=nginx --replicas=2

## Switch to admin again
kubectl config use-context minikube

## Now we will grant administrator access in the namespace

kubectl apply -f ./yaml/02-ns-admin-role.yaml
kubectl apply -f ./yaml/04-salme-ns-admin.yaml

## Switch to the user and let's try deploying

kubectl config use-context jsalmeron@minikube
kubectl run -n test nginx --image=nginx --replicas=2
kubectl get pods -n test -w
kubectl expose deployment nginx -n test --type=NodePort --port=80
kubectl get svc -n test

kubectl run nginx --image=nginx --replicas=2

## Finally, we will grant the user full pod read access

kubectl config use-context minikube
kubectl apply -f ./yaml/05-all-pods-access.yaml
kubectl apply -f ./yaml/06-salme-reads-all-pods.yaml

## Test now

kubectl config use-context jsalmeron@minikube
kubectl get pods -n test
kubectl get pods
kubectl get pods -n kube-system

kubectl get svc
kubectl run nginx --image=nginx --replicas=2
