#!/bin/bash


echo "Generating the Gossip encryption key..."

export GOSSIP_ENCRYPTION_KEY=$(consul keygen)


echo "Creating the Consul Secret to store the Gossip key and the TLS certificates..."

kubectl create secret generic consul \
  --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
  --from-file=certs/ca.pem \
  --from-file=certs/consul.pem \
  --from-file=certs/consul-key.pem


echo "Storing the Consul config in a ConfigMap..."

kubectl create configmap consul --from-file=consul/config.json


echo "Creating the Consul Service..."

kubectl create -f consul/service.yaml

echo "Creating the Consul Persitent Volumes.."

kubectl create -f consul/pv_consul0.yaml 
kubectl create -f consul/pv_consul1.yaml 
kubectl create -f consul/pv_consul2.yaml

echo "Creating the Consul StatefulSet..."

kubectl create -f consul/statefulset.yaml


echo "Creating a Secret to store the Vault TLS certificates..."

kubectl create secret generic vault \
    --from-file=certs/ca.pem \
    --from-file=certs/vault.pem \
    --from-file=certs/vault-key.pem


echo "Storing the Vault config in a ConfigMap..."

kubectl create configmap vault --from-file=vault/config.json


echo "Creating the Vault Service..."

kubectl create -f vault/service.yaml


echo "Creating the Vault Deployment..."

kubectl apply -f vault/deployment.yaml


echo "All done! ..."

