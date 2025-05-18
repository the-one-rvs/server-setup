# Extract manually
SECRET="argocd-manager-token"

TOKEN=$(kubectl -n kube-system get secret $SECRET -o jsonpath="{.data.token}" | base64 --decode)

CA_CRT=$(kubectl -n kube-system get secret $SECRET -o jsonpath="{.data['ca\.crt']}" | base64 --decode)

API_SERVER=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name==\"$(kubectl config current-context)\")].cluster.server}")
