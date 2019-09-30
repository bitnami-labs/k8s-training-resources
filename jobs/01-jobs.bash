# Let's deploy a WordPress installation

kubectl create ns job-example

kubectl create -n job-example -f wordpress-yaml/

# Let's deploy a faulty job

kubectl create -n job-example -f yaml/01-faulty-job.yaml

# Check the pods

kubectl get pods -n job-example -w

# Deploy a working job now

kubectl create -n job-example -f yaml/02-good-job.yaml

# Check the pods

kubectl get pods -n job-example

# Check the pods

kubectl get jobs -n job-example

# Delete the namespace

kubectl delete ns job-example
