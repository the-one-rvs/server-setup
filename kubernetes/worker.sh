#!/bin/bash
set -e

echo "[1/6] Ensuring containerd is configured properly..."
# Check and patch containerd config
CONFIG_FILE="/etc/containerd/config.toml"
if ! grep -q "SystemdCgroup = true" "$CONFIG_FILE"; then
    echo "Patching containerd config to enable SystemdCgroup..."
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' "$CONFIG_FILE"
    sudo systemctl restart containerd
fi
sudo systemctl enable containerd

echo "[2/6] Installing Kubernetes tools..."
# Add Kubernetes repo if not already present
if [ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
    sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
fi

sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "[3/6] Disabling swap and configuring networking sysctl..."
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

echo "[4/6] Waiting for you to paste the kubeadm join command..."
read -p "👉 Paste the full kubeadm join command from the master node: " JOIN_COMMAND

echo "[5/6] Running kubeadm join..."
sudo $JOIN_COMMAND

echo "[6/6] Verifying node status (wait on master node)..."
echo "✅ Node should appear on 'kubectl get nodes' from master in a few moments."
