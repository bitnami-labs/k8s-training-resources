## Pod Autoscaler

# (Minikube) Enable metrics-server addon
minikube addons enable metrics-server

# (GKE) Enabled by default

# Create a deployment for a simple php-apache application
kubectl run php-apache --image=k8s.gcr.io/hpa-example --requests=cpu=200m --expose --port=80
# Create Horizontal Pod Autoscaler
kubectl create -f yaml/01-hpa-apache-php.yaml
# Increase load
kubectl run -i --tty load-generator --image=busybox /bin/sh

while true; do wget -q -O- http://php-apache.default.svc.cluster.local; done

# In different terminals, check hpa and pod statuses
kubectl get hpa -w
kubectl get pods -w

# Cleaning
kubectl delete deployment php-apache
kubectl delete svc php-apache
kubectl delete hpa php-apache
kubectl delete deployment load-generator