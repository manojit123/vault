#!/bin/bash

echo "Creating CA , TLS and Private Key..."

cfssl gencert -initca certs/config/ca-csr.json | cfssljson -bare certs/ca

cfssl gencert -ca=certs/ca.pem -ca-key=certs/ca-key.pem -config=certs/config/ca-config.json -profile=default certs/config/consul-csr.json | cfssljson -bare certs/consul

cfssl gencert -ca=certs/ca.pem -ca-key=certs/ca-key.pem -config=certs/config/ca-config.json -profile=default certs/config/vault-csr.json | cfssljson -bare certs/vault


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

POD=$(kubectl get pods -o=name | grep consul | sed "s/^.\{4\}//")

while true; do
  STATUS=$(kubectl get pods ${POD} -o jsonpath="{.status.phase}")
  if [ "$STATUS" == "Running" ]; then
    break
  else
    echo "Pod status is: ${STATUS}"
    sleep 5
  fi
done

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
