#!/bin/bash

# Exit on error
set -e

# Install required dependencies
echo "Updating and installing dependencies..."
sudo apt update -y
sudo apt install -y openjdk-11-jdk wget curl sudo unzip

# Create a nexus user and group
echo "Creating Nexus user..."
sudo useradd -M -d /opt/nexus -s /bin/false nexus

# Download Nexus Repository OSS
echo "Downloading Nexus Repository OSS..."
cd /opt
sudo wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz

# Extract and set permissions
echo "Extracting Nexus..."
sudo tar -xvf latest-unix.tar.gz
sudo mv nexus-3* nexus
sudo chown -R nexus:nexus nexus sonatype-work

# Configure Nexus to run as Nexus user
echo "Configuring Nexus to run as Nexus user..."
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/bin/nexus.rc

# Create a systemd service for Nexus
echo "Creating systemd service..."
cat << EOF | sudo tee /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new service
echo "Reloading systemd and enabling Nexus service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

# Check if Nexus is running
echo "Checking Nexus status..."
sudo systemctl status nexus

# Display the admin password to access Nexus UI
echo "Nexus is running. You can access it on http://<your-vm-ip>:8081"
echo "Admin password (for initial login) is:"
sudo cat /opt/sonatype-work/nexus3/admin.password

# Set up a basic configuration (optional)
# You can create a script to set up repositories (Maven, Helm, Docker) via Nexus UI or REST API.

# End of script
echo "Nexus setup complete!"
