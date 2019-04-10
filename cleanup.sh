#!/bin/bash

echo "Deleting the Vault Deployment..."

kubectl delete -f vault/deployment.yaml

echo "Deleting the Vault Service..."

kubectl delete -f vault/service.yaml

echo "Deleting the Vault config in a ConfigMap..."

kubectl delete configmap vault

echo "Deleting a Secret to store the Vault TLS certificates..."

kubectl delete secret vault

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

kubectl delete secret consul

echo "Deleting Certificates ..."

rm -f certs/*.crt certs/*.pem

echo "Deleting Pertitent Volumes...."

kubectl delete pvc data-consul-0
kubectl delete pvc data-consul-0
kubectl delete pvc data-consul-2

while true; do
  STATUS=$(kubectl get pvc |grep consul|wc -l)
  if [ "$STATUS" == 0 ]; then
     break
  else
     sleep 10
     PVC=$(kubectl get pvc |grep consul |awk '{print $1}')
     kubectl delete pvc ${PVC}
  fi
done

kubectl delete -f consul/pv_consul0.yaml
kubectl delete -f consul/pv_consul1.yaml
kubectl delete -f consul/pv_consul2.yaml

echo "All Clean UP done! ..."
