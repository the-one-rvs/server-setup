#!/bin/bash

echo "[INFO] Joining Kubernetes cluster..."
sudo kubeadm join 192.168.86.133:6443 --token dpr81w.lca29w5u0a8dpsur --disco very-token-ca-cert-hash sha256:5f956ef9b17ef6892d4f2068c13725b68ccc83342d74decdc32e6785b850f95a
