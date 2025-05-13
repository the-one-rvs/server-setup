sudo apt update
sudo apt install openjdk17-jdk
echo "deb https://releases.jfrog.io/artifactory/artifactory-debs xenial main" | sudo tee -a /etc/apt/sources.list.d/artifactory.list
curl -fsSL  https://releases.jfrog.io/artifactory/api/gpg/key/public|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/artifactory.gpg
sudo apt update
sudo apt install jfrog-artifactory-oss -y
sudo systemctl start artifactory.service
sudo systemctl enable artifactory.service
sudo systemctl status artifactory.service