VERSION=v0.32.4  # <- replace with latest if needed
wget https://github.com/derailed/k9s/releases/download/${VERSION}/k9s_Linux_amd64.tar.gz
tar -zxvf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/
