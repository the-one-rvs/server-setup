#!/bin/bash

set -e

echo "[+] Updating system..."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "[+] Importing MongoDB GPG key..."
curl -fsSL https://pgp.mongodb.com/server-5.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-5.0.gpg --dearmor

echo "[+] Creating MongoDB source list..."
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-5.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list

echo "[+] Updating package index..."
sudo apt-get update -y

echo "[+] Installing MongoDB 5.0..."
sudo apt-get install -y mongodb-org

echo "[+] Starting and enabling mongod service..."
sudo systemctl start mongod
sudo systemctl enable mongod

echo "[+] Checking mongod status..."
sudo systemctl status mongod --no-pager

echo "[+] MongoDB installation completed."
mongod --version
