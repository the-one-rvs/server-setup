#!/bin/bash
set -e

# ---- Step 1: Ensure containerd is configured ----
echo "[Step 1] Ensuring containerd config is correct..."
CONFIG="/etc/containerd/config.toml"
if [ ! -f "$CONFIG" ]; then
    echo "Generating containerd config..."
    sudo mkdir -p /etc/containerd
    sudo containerd config default | sudo tee "$CONFIG"
fi

if ! grep -q 'SystemdCgroup = true' "$CONFIG"; then
    echo "Patching containerd to enable SystemdCgroup..."
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' "$CONFIG"
    sudo systemctl restart containerd
fi

sudo systemctl enable containerd
sudo systemctl start containerd

# ---- Step 2: Install kubelet, kubeadm, kubectl ----
echo "[Step 2] Installing Kubernetes tools..."
if [ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
    sudo mkdir -p /etc/apt/keyrings
    sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
fi

sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# ---- Step 3: Disable swap and configure sysctl ----
echo "[Step 3] Disabling swap and configuring sysctl..."
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

# ---- Step 4: Initialize kubeadm with Calico CIDR ----
echo "[Step 4] Initializing kubeadm cluster with Calico..."
sudo kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --cri-socket /run/containerd/containerd.sock \
  | tee kubeadm-init.log

# ---- Step 5: Setup kubeconfig for kubectl ----
echo "[Step 5] Configuring kubectl..."
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# ---- Step 6: Install Calico CNI ----
echo "[Step 6] Installing Calico CNI..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

# ---- Step 7: Save Join Command ----
echo "[Step 7] Extracting kubeadm join command..."
grep -A 2 "kubeadm join" kubeadm-init.log > join-command.txt
chmod 600 join-command.txt
echo "Join command saved to join-command.txt"

# ---- Step 8: Wait for nodes to be Ready ----
echo "Waiting for all system pods to become Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s
kubectl get nodes -o wide
kubectl get pods -n kube-system

echo "✅ Kubernetes master node is ready with Calico networking."
