set -x

openssl genrsa -out client.key 4096
openssl req -new -out client.csr -key client.key
openssl x509 -req -days 365 -in client.csr -signkey client.key -out client.pem
rm client.csr
keytool -genkeypair -alias broker -keyalg RSA -keysize 4096 -keystore broker.ks
keytool -import -alias client -keystore broker.ts -file client.pem
keytool -exportcert -rfc -alias broker -keystore broker.ks -file broker.pem
