# Demo OCP non-HTTP Ingress Traffic with Redis

```
git clone ...
cd ...
crc start
eval $(crc oc-env)
oc login -u kubeadmin https://api.crc.testing:6443
./install.sh
export REDIS_PASSWORD=$(oc get secret --namespace redis my-release-redis -o jsonpath="{.data.redis-password}" | base64 -d) 
echo $REDIS_PASSWORD
podman run -ti -v ./ca.pem:/tmp/ca.pem:z -v ./cert.key:/tmp/cert.key:z -v ./cert.pem:/tmp/cert.pem:z docker.io/bitnami/redis:7.4.1-debian-12-r0 /bin/bash
REDISCLI_AUTH="notarealpassword" redis-cli -h redis.apps-crc.testing -p 443 --insecure --tls --cert /tmp/cert.pem --key /tmp/cert.key --cacert /tmp/ca.pem --sni redis.apps-crc.testing
> set mykey "Hello"
> get mykey
```
