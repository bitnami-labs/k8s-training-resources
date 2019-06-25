#!/bin/bash

# Create a namespace for team-api

kubectl create ns team-api

# Let's deploy a basic quota

kubectl create -f yaml/01-namespace-quotas.yaml

# Now we will deploy one database

kubectl create -f yaml/02-db-pod.yaml

# Check the resource quota usage

kubectl get resourcequota -n team-api api-team-quota -o yaml

# Let us try to deploy another database

kubectl create -f yaml/03-db-pod-fail.yaml

# Finally, let us check the pod resource consumption

minikube addons enable heapster

kubectl top pod

# Set a limit to the namespace

kubectl create -f yaml/04-limit.yaml

# Try deploying a pod that requires more cpu

kubectl create -f yaml/05-db-pod-fail.yaml
