#!/bin/bash

set +x

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

oc create ns redis

rm -f cert.pem cert.key ca.pem
openssl req -x509 -newkey rsa:4096 -keyout cert.key -out cert.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=redis.apps-crc.testing"
cp cert.pem ca.pem
chmod 644 cert.key

kubectl create secret generic redis-tls --from-file=./cert.pem --from-file=./cert.key --from-file=./ca.pem -n redis
helm install -n redis -f values.yaml my-release bitnami/redis
#helm uninstall -n redis my-release
oc apply -f route.yml -n redis

#To get your password run:                                                                                                                                                                                                                                                                 
#                                                                                                                                                                                                                                                                                          
#    export REDIS_PASSWORD=$(kubectl get secret --namespace redis my-release-redis -o jsonpath="{.data.redis-password}" | base64 -d)                                                                                                                                                       
#                                                                                                                                                                                                                                                                                          
#To connect to your Redis&reg; server:                                                                                                                                                                                                                                                     
#
#1. Run a Redis&reg; pod that you can use as a client:
#
#   kubectl run --namespace redis redis-client --restart='Never'  --env REDIS_PASSWORD=$REDIS_PASSWORD  --image docker.io/bitnami/redis:7.0.11-debian-11-r12 --command -- sleep infinity                                                                                                  
#
#   Copy your TLS certificates to the pod:
#
#   kubectl cp --namespace redis /path/to/client.cert redis-client:/tmp/client.cert
#   kubectl cp --namespace redis /path/to/client.key redis-client:/tmp/client.key
#   kubectl cp --namespace redis /path/to/CA.cert redis-client:/tmp/CA.cert
#
#   Use the following command to attach to the pod:
#
#   kubectl exec --tty -i redis-client \
#   --namespace redis -- bash
#
#2. Connect using the Redis&reg; CLI:
#   REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h my-release-redis-master --tls --cert /tmp/client.cert --key /tmp/client.key --cacert /tmp/CA.cert                                                                                                                                        
#
#To connect to your database from outside the cluster execute the following commands:
#
#    kubectl port-forward --namespace redis svc/my-release-redis-master 6379:6379 &
#    REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h 127.0.0.1 -p 6379 --tls --cert /tmp/client.cert --key /tmp/client.key --cacert /tmp/CA.cert

# Test Redis
# $ export REDIS_PASSWORD=$(oc get secret --namespace redis my-release-redis -o jsonpath="{.data.redis-password}" | base64 -d) 
# $ podman run -ti -v ./ca.pem:/tmp/ca.pem:z -v ./cert.key:/tmp/cert.key:z -v ./cert.pem:/tmp/cert.pem:z docker.io/bitnami/redis:7.4.1-debian-12-r0 /bin/bash
# $ REDISCLI_AUTH="notarealpassword" redis-cli -h redis.apps-crc.testing -p 443 --insecure --tls --cert /tmp/cert.pem --key /tmp/cert.key --cacert /tmp/ca.pem --sni redis.apps-crc.testing
# redis.apps-crc.testing:443> set mykey "Hello"
# OK
# redis.apps-crc.testing:443> get mykey
# "Hello"

