# Run daemon set from yaml folder

k create -f yaml/01-daemonset.yaml

# Get pods and check how each of them is in a different node

# Clean up
k delete -f yaml/

# Switch to minikube context
kubectx minikube