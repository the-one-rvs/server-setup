mkdir -p /data/cert
openssl req -newkey rsa:4096 -nodes -keyout /data/cert/harbor.key -x509 -out /data/cert/harbor.crt -days 365
