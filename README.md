# vault deployment

Create folder structure as below
================================
$ mkdir certs
$ mkdir certs/config
$ mkdir consul
$ mkdir vault

Create below files
==================
vi certs/config/ca-config.json

{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "default": {
        "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ],
        "expiry": "8760h"
      }
    }
  }
}

vi certs/config/ca-csr.json

{
  "hosts": [
    "gtslabs.ibm.com"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "ST": "Karnataka",
      "L": "Bangalore"
    }
  ]
}

vi certs/config/consul-csr.json

{
  "CN": "server.dc1.gtslabs.ibm.com",
  "hosts": [
    "server.dc1.gtslabs.ibm.com",
    "127.0.0.1"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "ST": "Karnataka",
      "L": "Bangalore"
    }
  ]
}


vi certs/config/vault-csr.json

{
  "hosts": [
    "vault",
    "127.0.0.1",
    "192.168.20.41"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "ST": "Karnataka",
      "L": "Bangalore"
    }
  ]
}


