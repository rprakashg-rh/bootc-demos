# influxdb

Build the image

```sh
podman build --secret id=creds,src=$HOME/.config/containers/auth.json \
     --authfile=$PULL_SECRET \
     -t "$REGISTRY/$REGISTRY_USER/influxdb-bootc" \
     -f Containerfile .
```

Testing the container

```sh
podman run \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    --rm \
    -it \
    --name influxdb-bootc --hostname influxdb-bootc -p 2022:22 $REGISTRY/$REGISTRY_USER/influxdb-bootc
```

Push to registry

```sh
podman push "$REGISTRY/$REGISTRY_USER/influxdb-bootc" 
```

Overlay cloud-init to base image

```sh
cd ../cloud-init

podman build \
    --build-arg=FROM=$REGISTRY/$REGISTRY_USER/influxdb-bootc \
    -t $REGISTRY/$REGISTRY_USER/influxdb-bootc:aws \
    -f Containerfile .
```

Push to registry

```sh
podman push $REGISTRY/$REGISTRY_USER/influxdb-bootc:aws
```

Build AMI using BiB

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
    --aws-ami-name influxdb-x86_64 \
    --aws-bucket bootc-amis \
    --aws-region us-west-2 \
    $REGISTRY/$REGISTRY_USER/influxdb-bootc:aws
```