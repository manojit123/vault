# vault HA deployment on K8s

Create a Certificate Authority:

$ cfssl gencert -initca certs/config/ca-csr.json | cfssljson -bare certs/ca

Then, create a private key and a TLS certificate for Consul:

$ cfssl gencert \
    -ca=certs/ca.pem \
    -ca-key=certs/ca-key.pem \
    -config=certs/config/ca-config.json \
    -profile=default \
    certs/config/consul-csr.json | cfssljson -bare certs/consul

Do the same for Vault:

$ cfssl gencert \
    -ca=certs/ca.pem \
    -ca-key=certs/ca-key.pem \
    -config=certs/config/ca-config.json \
    -profile=default \
    certs/config/vault-csr.json | cfssljson -bare certs/vault

Consul
======
Generate Gossip Encryption Key:

$ export GOSSIP_ENCRYPTION_KEY=$(consul keygen)

Store the key along with the TLS certificates in a Secret:

$ kubectl create secret generic consul \
  --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
  --from-file=certs/ca.pem \
  --from-file=certs/consul.pem \
  --from-file=certs/consul-key.pem

Create consul config map:

kubectl create configmap consul --from-file=consul/config.json

Create the Service:
kubectl create -f consul/service.yaml

Create persistent volumes: 

kubectl create -f consul/pv_consul0.yaml
kubectl create -f consul/pv_consul1.yaml
kubectl create -f consul/pv_consul2.yaml

Deploy a three-node Consul cluster:
kubectl create -f consul/statefulset.yaml

Forward the port to the local machine:
kubectl port-forward consul-1 8500:8500 &

Ensure that all members are alive:

$ consul members
Handling connection for 8500
Node      Address            Status  Type    Build  Protocol  DC   Segment
consul-0  10.1.230.240:8301  alive   server  1.4.0  2         dc1  <all>
consul-1  10.1.255.165:8301  alive   server  1.4.0  2         dc1  <all>
consul-2  10.1.49.151:8301   alive   server  1.4.0  2         dc1  <all>

Vault
=====

Store the Vault TLS certificates that we created in a Secret:
$ kubectl create secret generic vault \
    --from-file=certs/ca.pem \
    --from-file=certs/vault.pem \
    --from-file=certs/vault-key.pem

Create vault configmap:
$ kubectl create configmap vault --from-file=vault/config.json

Create vault service
$ kubectl create -f vault/service.yaml

Deploy Vault in HA:
$ kubectl apply -f vault/deployment.yaml

Port-forward vault:
$ kubectl port-forward deploy/vault 8200:8200 &

Quick Test
==========

$ export VAULT_ADDR=https://127.0.0.1:8200
$ export VAULT_CACERT="certs/ca.pem"

$ vault operator init -key-shares=1 -key-threshold=1

Take note of the unseal key and the initial root token.

Unseal:
$ vault operator unseal

Authenticate with the root token:
$ vault login

Create a new secret:
$ vault kv put secret/precious foo=bar

Read:
$ vault kv get secret/precious


Deploy in a single step:
=======================

./create.sh

Clean UP:
=========

./cleanup.sh





















