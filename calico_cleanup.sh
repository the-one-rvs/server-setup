sudo rm -rf /etc/cni/net.d/*
sudo rm -rf /opt/cni/bin/calico*
sudo ip link delete cni0
sudo ip link delete flannel.1  # only if used before
sudo ip link delete cali* 2>/dev/null  # calico interfaces

ls -l /etc/cni/net.d/
sudo rm -rf /etc/cni/net.d/*
sudo ip link delete cni0 2>/dev/null
sudo ip link delete weave 2>/dev/null
sudo ip link delete cali* 2>/dev/null
sudo rm -rf /opt/cni/bin/calico*
sudo systemctl restart kubelet
kubectl delete -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')" --ignore-not-found
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
ls -l /etc/cni/net.d/
kubectl delete pod -n kube-system -l k8s-app=kube-dns
cat /etc/cni/net.d/*.conflist
