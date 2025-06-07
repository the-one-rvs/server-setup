# 1. Reset kubeadm (you've already done this)
sudo kubeadm reset -f

# 2. Stop kubelet and container runtime (e.g., containerd or Docker)
sudo systemctl stop kubelet
sudo systemctl stop containerd  # or docker if you're using Docker

# 3. Clean Kubernetes-related dirs
sudo rm -rf /etc/kubernetes/
sudo rm -rf /var/lib/etcd/
sudo rm -rf /var/lib/kubelet/
sudo rm -rf /etc/cni/net.d/
sudo rm -rf /opt/cni/bin/*
sudo rm -rf /var/lib/cni/
sudo rm -rf /run/flannel/

# 4. Clean old network interfaces (CNI leftovers)
sudo ip link delete cni0 || true
sudo ip link delete flannel.1 || true

# 5. Remove old kubeconfig (optional but recommended)
sudo rm -rf $HOME/.kube

# 6. Disable swap again (to be safe)
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 7. Restart runtime and kubelet
sudo systemctl start containerd
sudo systemctl daemon-reexec
sudo systemctl start kubelet
