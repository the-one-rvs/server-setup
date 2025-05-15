#!/bin/bash

echo "[1/6] Resetting kubeadm cluster..."
sudo kubeadm reset -f

echo "[2/6] Removing Kubernetes config and directories..."
sudo rm -rf ~/.kube
sudo rm -rf /etc/kubernetes
sudo rm -rf /var/lib/etcd
sudo rm -rf /var/lib/kubelet
sudo rm -rf /etc/cni
sudo rm -rf /opt/cni
sudo rm -rf /var/lib/cni
sudo rm -rf /etc/systemd/system/kubelet.service.d

echo "[3/6] Removing kubeadm, kubelet, kubectl..."
sudo apt-mark unhold kubelet kubeadm kubectl
sudo apt-get purge -y kubeadm kubelet kubectl
sudo apt-get autoremove -y

sudo ip link delete cni0
sudo ip link delete flannel.1
sudo rm -rf /run/flannel


echo "[4/6] Deleting Kubernetes APT sources..."
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "[5/6] Re-enabling swap (if desired)..."
sudo sed -i '/ swap / s/^#//' /etc/fstab
sudo swapon -a

echo "[6/6] Cleanup complete. containerd is untouched."
