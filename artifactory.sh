sudo apt update
sudo apt install openjdk-21-jdk -y
java -version

#--Jfrog Artifactory---#
wget https://releases.jfrog.io/artifactory/artifactory-oss/org/artifactory/oss/jfrog-artifactory-oss/7.77.3/jfrog-artifactory-oss-7.77.3-linux.tar.gz

# Extract
tar -xvzf jfrog-artifactory-oss-7.77.3-linux.tar.gz

# Move to /opt
sudo mv artifactory-oss-7.77.3 /opt/artifactory

cd /opt/artifactory/app/bin
./artifactory.sh start
