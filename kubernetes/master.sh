#!/bin/bash
set -e

# ---- Step 1: System Preparation ----
echo "[Step 1] Updating system and installing dependencies..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

# ---- Step 2: Install containerd ----
echo "[Step 2] Installing containerd..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y containerd.io

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# ---- Step 3: Install kubelet, kubeadm, kubectl ----
echo "[Step 3] Installing Kubernetes tools..."
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# ---- Step 4: Disable swap and configure sysctl ----
echo "[Step 4] Disabling swap and configuring sysctl..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# ---- Step 5: Initialize Control Plane with Calico CIDR ----
echo "[Step 5] Initializing kubeadm cluster..."
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 | tee kubeadm-init.log

# ---- Step 6: Setup kubectl config for current user ----
echo "[Step 6] Setting up kubeconfig..."
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# ---- Step 7: Install Calico CNI ----
echo "[Step 7] Installing Calico CNI..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

# ---- Step 8: Extract Join Command ----
echo "[Step 8] Extracting kubeadm join command..."
grep -A 2 "kubeadm join" kubeadm-init.log > join-command.txt
chmod 600 join-command.txt
echo "Join command saved to join-command.txt"

# ---- Final Checks ----
echo "Waiting for all system pods to become Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s
kubectl get nodes -o wide
kubectl get pods -n kube-system

echo "✅ Kubernetes master node is ready with Calico networking."
