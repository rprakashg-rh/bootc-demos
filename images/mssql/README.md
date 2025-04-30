# Microsoft SQL Server on RHEL Image Mode

Build the image

```sh
cd images/mssql

podman build \
    --secret id=creds,src=$HOME/.config/containers/auth.json \
    --authfile=$PULL_SECRET -t "$REGISTRY/$REGISTRY_USER/mssql-bootc" \
    -f Containerfile .
```

Testing the image
```sh
podman run \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    --rm \
    -it \
    --name mssql \
    --hostname mssql -p 1433:1433 $REGISTRY/$REGISTRY_USER/mssql-bootc:latest
```

Push image to registry
```sh
 podman push quay.io/rgopinat/mssql-bootc:latest
```

Build ISO

Overlay cloud-init

```sh
cd ../cloud-init

podman build \
--build-arg=FROM=$REGISTRY/$REGISTRY_USER/rhde-opa \
-t $REGISTRY/$REGISTRY_USER/mssql-bootc:aws \
-f Containerfile .
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
--aws-ami-name mssql-bootc-x86_64 \
--aws-bucket bootc-amis \
--aws-region us-west-2 \
$REGISTRY/$REGISTRY_USER/mssql-bootc:aws
```
