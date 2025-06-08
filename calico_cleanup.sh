sudo rm -rf /etc/cni/net.d/*
sudo rm -rf /opt/cni/bin/calico*
sudo ip link delete cni0
sudo ip link delete flannel.1  # only if used before
sudo ip link delete cali* 2>/dev/null  # calico interfaces
