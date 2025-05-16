#!/bin/bash

# === CONFIGURATION ===
HARBOR_URL="192.168.86.113:80"
HARBOR_USERNAME="admin"
HARBOR_PASSWORD="Monitor1!"
CONTAINERD_CERTS_DIR="/etc/containerd/certs.d/$HARBOR_URL"
HOSTS_FILE="$CONTAINERD_CERTS_DIR/hosts.toml"

# === Create containerd registry config ===
echo "[*] Creating containerd hosts.toml for Harbor..."

sudo mkdir -p "$CONTAINERD_CERTS_DIR"

sudo tee "$HOSTS_FILE" > /dev/null <<EOF
server = "http://$HARBOR_URL"

[host."http://$HARBOR_URL"]
  capabilities = ["pull", "resolve", "push"]
  skip_verify = true
  username = "$HARBOR_USERNAME"
  password = "$HARBOR_PASSWORD"
EOF

# sudo chmod 600 "$HOSTS_FILE"

# === Restart containerd ===
echo "[*] Restarting containerd..."
sudo systemctl restart containerd


