sudo apt update
sudo apt install openjdk-21-jdk -y

curl -sL https://bintray.com/jfrog/artifactory-rpms/rpm > /etc/apt/sources.list.d/jfrog.list
sudo apt update
sudo apt install jfrog-artifactory-oss -y
sudo systemctl enable artifactory
sudo systemctl start artifactory
sudo systemctl status artifactory
