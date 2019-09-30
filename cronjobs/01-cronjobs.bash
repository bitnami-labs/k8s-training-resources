## Jobs / Cron Jobs

# Create MariaDB database
kubectl create -f yaml/mariadb-secret.yaml
kubectl create -f yaml/mariadb-svc.yaml
kubectl create -f yaml/mariadb-sts.yaml
while [ "$(kubectl get sts mariadb -o jsonpath='{.status.readyReplicas}')" != "1" ]; do sleep 5; done

# Deploy a faulty job
kubectl create -f yaml/faulty-job.yaml

# Check the jobs/pods
kubectl get jobs
kubectl get pods -l app.kubernetes.io/name=faulty-create-table
kubectl logs "$(kubectl get pods -l app.kubernetes.io/name=faulty-create-table -o jsonpath='{.items[0].metadata.name}')"

# Deploy a working job
kubectl create -f yaml/good-job.yaml

# Check the jobs/pods
kubectl get jobs
kubectl get pods -l app.kubernetes.io/name=good-create-table
kubectl logs "$(kubectl get pods -l app.kubernetes.io/name=good-create-table -o jsonpath='{.items[0].metadata.name}')"

# Check database
kubectl exec -it mariadb-0 -- bash
mysql --user="$MARIADB_USER" --password="$MARIADB_PASSWORD" --database="$MARIADB_DATABASE"
show tables;
exit

# Create a Cron Job to backup the database
kubectl create -f yaml/backups-pvc.yaml
kubectl create -f yaml/backups-cronjob.yaml

# Check the cronjobs/jobs/pods
kubectl get cronjobs
kubectl get jobs -w
kubectl get pods -l app.kubernetes.io/name=backup-database
kubectl logs "$(kubectl get pods -l app.kubernetes.io/name=backup-database -o jsonpath='{.items[0].metadata.name}')"

# Check backups
kubectl delete cronjob backup-database
kubectl create -f yaml/minideb-pod.yaml
kubectl exec minideb -- ls -la /backups

# Cleaning
kubectl delete pod minideb
kubectl delete pvc mariadb-backups
kubectl delete secret mariadb
kubectl delete svc mariadb
kubectl delete sts mariadb
kubectl delete pvc data-mariadb-0
kubectl delete job faulty-create-table
kubectl delete job good-create-table