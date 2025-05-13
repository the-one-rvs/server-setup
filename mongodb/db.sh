#!/bin/bash

# Update system package list
sudo apt update

# Install prerequisites
sudo apt install -y gnupg wget

# Add the MongoDB 5.0 public GPG key
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -

# Add MongoDB 5.0 repository to sources list
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list

# Update package list again after adding MongoDB repository
sudo apt update

# Install MongoDB 5.0
sudo apt install -y mongodb-org
