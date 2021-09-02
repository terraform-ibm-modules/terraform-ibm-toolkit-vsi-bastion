#!/usr/bin/env bash

PUBLIC_IP=$(cat .public-ip)

echo "Private key"
cat .private-key

echo "Connecting to ssh server: ${PUBLIC_IP}"

ssh -i .private-key root@$(cat .public-ip) ls
