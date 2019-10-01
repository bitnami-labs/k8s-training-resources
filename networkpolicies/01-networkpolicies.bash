# First let us deploy a helm chart

helm install stable/wordpress --name mywp

# Complete the missing information in yaml/example_policy.yaml and then deploy it

kubectl create -f yaml/example_policy.yaml

# Let's check now

kubectl run -ti mysqlclient --image=bitnami/mariadb -- sh

# Run the mysql client

mysql -uroot -h mywp-mariadb

# Check if it works
