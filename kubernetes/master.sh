#!/bin/bash
# set -e

# Update the system and install dependencies
sudo apt-get update
sudo apt install apt-transport-https curl -y

# Install containerd
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install containerd.io -y

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Install Kubernetes components
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Configure networking
sudo modprobe br_netfilter
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl --system

# Initialize control plane
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 | tee kubeadm-init.log

# Configure kubectl for the user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install CNI (Flannel)
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Print join command for worker nodes
echo "Save the join command from kubeadm-init.log to use on worker nodes"
sudo kubeadm init \
    --pod-network-cidr=10.244.0.0/16 \
    --ignore-preflight-errors=Mem \
    | tee kubeadm-init.log || {
        echo "Failed to initialize control plane"
        exit 1
    }

# Wait for admin.conf to be created
echo "Waiting for admin.conf to be created..."
for i in {1..30}; do
    if [ -f /etc/kubernetes/admin.conf ]; then
        break
    fi
    sleep 5
done

if [ ! -f /etc/kubernetes/admin.conf ]; then
    echo "Timeout waiting for admin.conf"
    exit 1
fi

# Configure kubectl for the user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install CNI (Flannel)
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Extract and save join command
grep -A 2 "kubeadm join" kubeadm-init.log > join-command.txt
chmod 600 join-command.txt
echo "Join command saved to join-command.txt"

# Verify cluster status
echo "Verifying cluster status..."
kubectl get nodes
kubectl get pods --all-namespaces