#!/bin/bash

echo "Deleting the Vault Deployment..."

kubectl delete -f vault/deployment.yaml

echo "Deleting the Vault Service..."

kubectl delete -f vault/service.yaml

echo "Deleting the Vault config in a ConfigMap..."

kubectl delete configmap vault 

echo "Deleting a Secret to store the Vault TLS certificates..."

kubectl delete secret generic vault 

echo "Deleting the Consul StatefulSet..."

kubectl delete -f consul/statefulset.yaml
 
POD=$(kubectl get pods -o=name | grep consul | sed "s/^.\{4\}//")

while true; do
  STATUS=$(kubectl get pods ${POD} -o jsonpath="{.status.phase}")
  if [ "$STATUS" == "Terminating" ]; then
    sleep 10
  else
    break 
  fi
done

echo "Deleting the Consul Service..."

kubectl delete -f consul/service.yaml

echo "deleting the Consul config in a ConfigMap..."

kubectl  delete configmap consul 

echo "Deleting the Consul Secret to store the Gossip key and the TLS certificates..."

kubectl delete secret generic consul 

echo "Deleting Certificates ..."

rm -y certs/*.crt certs/*.pem
 
echo "Deleting Pertitent Volumes...."

kubectl delete pvc data-consul-0
kubectl delete pvc data-consul-0
kubectl delete pvc data-consul-2

kubectl delete -f consul/pv_consul0.yaml
kubectl delete -f consul/pv_consul1.yaml
kubectl delete -f consul/pv_consul2.yaml

echo "All Clean UP done! ..."

