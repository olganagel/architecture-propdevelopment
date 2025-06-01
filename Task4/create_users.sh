#!/bin/bash

mkdir -p users && cd users

USERS=(
  "admin-user:admins"
  "ns-admin-user:namespace-admins"
  "developer-user:developers"
  "auditor-user:auditors"
  "viewer-user:viewers"
)

for user_data in "${USERS[@]}"; do
  user=$(echo "$user_data" | cut -d':' -f1)
  group=$(echo "$user_data" | cut -d':' -f2)

  openssl genrsa -out "$user.key" 2048
  openssl req -new -key "$user.key" -out "$user.csr" -subj "/CN=$user/O=$group"
  openssl x509 -req -in "$user.csr" -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out "$user.crt" -days 365
  kubectl config set-credentials "$user" --client-certificate="$user.crt" --client-key="$user.key"
  kubectl config set-context "$user-context" --cluster=minikube --user="$user"
done