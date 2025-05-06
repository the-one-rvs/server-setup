sudo apt update
sudo apt install openjdk-21-jdk -y
java -version

#--Jfrog Artifactory---#
curl -g -L -O -J 'https://releases.jfrog.io/artifactory/artifactory-pro/org/artifactory/pro/jfrog-artifactory-pro/[RELEASE]/jfrog-artifactory-pro-[RELEASE]-linux.tar.gz'

# Extract
tar -xvf jfrog-artifactory-pro-7.104.10-linux.tar.gz

# Move to /opt
sudo mv artifactory-oss-7.77.3 /opt/artifactory

cd /opt/artifactory/app/bin
./artifactory.sh start
