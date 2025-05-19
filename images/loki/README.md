# Grafana loki
RHEL image mode image for running Grafana loki 

```sh
cd images/loki

podman build --secret id=creds,src=$HOME/.config/containers/auth.json \
     --authfile=$PULL_SECRET \
     -t "$REGISTRY/$REGISTRY_USER/loki-bootc" \
     -f Containerfile .
```

Push the image to registry

```sh
podman push "$REGISTRY/$REGISTRY_USER/loki-bootc"
```

Overlay cloud-init and tag the image with `aws`

```sh
cd ../cloud-init

podman build \
    --build-arg=FROM=$REGISTRY/$REGISTRY_USER/loki-bootc \
    -t $REGISTRY/$REGISTRY_USER/loki-bootc:aws \
    -f Containerfile .
```

Push the image to registry

```sh
podman push $REGISTRY/$REGISTRY_USER/loki-bootc:aws
```

Build the AMI using BiB

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
    --aws-ami-name loki-x86_64 \
    --aws-bucket bootc-amis \
    --aws-region us-west-2 \
    $REGISTRY/$REGISTRY_USER/loki-bootc:aws
```