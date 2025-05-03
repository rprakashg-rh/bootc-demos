# FlightCTL demo

## Building Container Image

```sh
podman build --secret id=creds,src=$HOME/.config/containers/auth.json \
    --secret id=gateway-admin-password,src=$HOME/secrets/gateway-admin-password \
    --authfile=$PULL_SECRET \
    -t "$REGISTRY/$REGISTRY_USER/edge-device" \
    -f Containerfile .
```

Overlay cloud-init

```sh
cd ../cloud-init

podman build \
    --build-arg=FROM=$REGISTRY/$REGISTRY_USER/edge-device \
    -t $REGISTRY/$REGISTRY_USER/edge-device:aws \
    -f Containerfile .
```

Push image to registry

```sh
podman push $REGISTRY/$REGISTRY_USER/edge-device:aws
```
## Build ISO using BiB

## Build AMI using BiB

```sh
sudo podman run \
    --authfile=$PULL_SECRET \
    --rm \
    --privileged \
    --security-opt label=type:unconfined_t \
    --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    --env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
    --env AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    registry.redhat.io/rhel9/bootc-image-builder:latest \
    --local \
    --type ami \
    --aws-ami-name edge-device-x86_64 \
    --aws-bucket bootc-amis \
    --aws-region us-west-2 \
    $REGISTRY/$REGISTRY_USER/edge-device:aws
```

## Generate the enrollment credentials

Get demouser password

```sh
kubectl get secret/keycloak-demouser-secret -n flightctl -o=jsonpath='{.data.password}' | base64 -d | pbcopy
```

Login to FlightCTL

```sh
./bin/flightctl login $FC_API_URL -u demouser -p $FC_PASS --insecure-skip-tls-verify
```

Get enrollment credentials

```sh
./bin/flightctl certificate request --signer=enrollment --expiration=365d --output=embedded > $HOME/secrets/agentconfig.yaml
```
