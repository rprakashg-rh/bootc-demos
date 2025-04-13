# Red Hat Device Edge with Open Policy Agent

```sh
podman build \
    --secret id=creds,src=$HOME/.config/containers/auth.json \
    --authfile=$PULL_SECRET -t "$REGISTRY/$REGISTRY_USER/rhde-opa" \
    --build-arg=ADMIN_USER_PASSWORD=${ADMIN_USER_PASSWORD} \
    -f Containerfile .
```

Testing the bootc image

```sh
podman run -v /var/lib/containers/storage:/var/lib/containers/storage --rm -it --name rhde-opa --hostname rhde-opa -p 2022:22 quay.io/rgopinat/rhde-opa
```
Push to registry

```sh
podman push $REGISTRY/$REGISTRY_USER/rhde-opa
```

## Build ISO


## Build AMI

```sh
podman build \
--build-arg=FROM=quay.io/rgopinat/rhde-opa \
-t quay.io/rgopinat/rhde-opa-aws \
-f Containerfile .
```

Push to registry

```sh
podman push quay.io/rgopinat/rhde-opa-aws
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
--aws-ami-name rhde-opa-x86_64 \
--aws-bucket bootc-amis \
--aws-region us-west-2 \
$REGISTRY/$REGISTRY_USER/rhde-opa-aws
```


