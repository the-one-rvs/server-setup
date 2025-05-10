#!/bin/bash

echo "[INFO] Joining Kubernetes cluster..."
kubeadm join 192.168.86.133:6443 --token g8jjah.d6a15m0w8jj56mu13 \
    --discovery-token-ca-cert-hash sha256:5f956ef9b17ef6892d4f2068c13725b68ccc83342d74dedcc32e6785b850f95a

