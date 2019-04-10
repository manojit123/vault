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

echo "Deleting the Consul Service..."

kubectl delete -f consul/service.yaml

echo "deleting the Consul config in a ConfigMap..."

kubectl  delete configmap consul 

echo "Deleting the Consul Secret to store the Gossip key and the TLS certificates..."

kubectl delete secret generic consul 

echo "All Clean UP done! ..."

