#!/bin/bash

# This script joins the worker node to the Kubernetes cluster

JOIN_CMD="kubeadm join 192.168.86.133:6443 \
--token gpgq2t.5lqwg7lnzmthalwp \
--discovery-token-ca-cert-hash sha256:5f956ef9b17ef6892d4f2068c13725b68ccc83342d74dedc32e6785b850f95a"

echo "[INFO] Joining the Kubernetes cluster..."
sudo $JOIN_CMD
