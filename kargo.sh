curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add kargo https://charts.kargo.akuity.io
helm repo update

kubectl create ns kargo

helm install kargo kargo/kargo \
  --namespace kargo \
  --set ui.enabled=true \
  --set ui.service.type=NodePort  # or LoadBalancer/Ingress
