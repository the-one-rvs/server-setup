#!/bin/bash

set -e

# --------------------------------------
# CONFIGURATION (Update These)
# --------------------------------------

SPIN_USER="spinnaker"
DOCKER_REGISTRY_NAME="harbor-registry"
DOCKER_REGISTRY_URL="192.168.86.113"
DOCKER_USERNAME="admin"
DOCKER_PASSWORD="Monitor1!"

# GITHUB_USERNAME="your-github-username"
# GITHUB_TOKEN="your-github-token"

# --------------------------------------
# 1. Create User and Install Basics
# --------------------------------------


sudo apt update
sudo apt install -y openjdk-17-jdk curl unzip apt-transport-https gnupg2 git 

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker permission fix
sudo usermod -aG docker "$USER"
newgrp docker

# --------------------------------------
# 2. Install Halyard
# --------------------------------------

curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh --user "$USER"

# Shell fix for Halyard
source ~/.bashrc

# --------------------------------------
# 3. Configure Spinnaker with Halyard
# --------------------------------------

# Set version
hal config version edit --version $(hal version latest -q)

# Choose deployment type
hal config deploy edit --type localdebian

# Set up Docker Registry (Harbor or DockerHub)
hal config provider docker-registry enable

hal config provider docker-registry account add $DOCKER_REGISTRY_NAME \
  --address $DOCKER_REGISTRY_URL \
  --username $DOCKER_USERNAME \
  --password $DOCKER_PASSWORD \
  --repositories joiller-image-library/alqo \
  --insecure-registry true

# --------------------------------------
# 4. Enable Artifacts (GitHub)
# --------------------------------------

# hal config features edit --artifacts true

# hal config artifact github enable
# hal config artifact github account add github-account \
#   --token $GITHUB_TOKEN \
#   --username $GITHUB_USERNAME

# --------------------------------------
# 5. Set UI and API ports (Deck and Gate)
# --------------------------------------

hal config security ui edit --override-base-url http://192.168.86.115:9000
hal config security api edit --override-base-url http://192.168.86.115:8084

# --------------------------------------
# 6. Deploy Spinnaker
# --------------------------------------

hal deploy apply

# --------------------------------------
# 7. Expose Deck (UI)
# --------------------------------------

sudo ufw allow 9000
sudo ufw allow 8084
echo "Spinnaker UI should now be available at http://192.168.86.115:9000"

# Optional: Start Halyard on boot
sudo systemctl enable halyard

# Final reminder
echo "✅ Spinnaker Installed."
echo "👉 Access UI: http://<vm-ip>:9000"
echo "👉 Default user: none (no auth enabled by default)"
