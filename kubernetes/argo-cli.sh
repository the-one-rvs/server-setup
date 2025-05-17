#!/bin/bash
set -e

# Set the version you want to install
ARGO_VERSION="v3.4.16"

# Download the binary
curl -sSL -o argo-linux-amd64.gz "https://github.com/argoproj/argo-workflows/releases/download/${ARGO_VERSION}/argo-linux-amd64.gz"

# Unzip
gunzip argo-linux-amd64.gz

# Make it executable
chmod +x argo-linux-amd64

# Move to /usr/local/bin
sudo mv argo-linux-amd64 /usr/local/bin/argo

# Verify installation
argo version