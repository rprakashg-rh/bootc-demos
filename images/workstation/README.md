# workstation
RHEL workstation image

Build the workstation image

```sh
sudo podman build \
    --secret id=creds,src=$HOME/.config/containers/auth.json \
    -f $PWD/images/workstation/Containerfile \
    -t quay.io/rgopinat/rhel9-bootc-workstation
```

Push to registry

```sh
sudo podman push quay.io/rgopinat/rhel9-bootc-workstation
```

Build ISO

```sh

sudo podman run \
--authfile=$PULL_SECRET \
--rm \
--privileged \
--pull=newer \
--security-opt label=type:unconfined_t \
-v $PWD/images/workstation/config.toml:/config.toml:ro \
-v $PWD/output:/output \
-v /var/lib/containers/storage:/var/lib/containers/storage \
quay.io/centos-bootc/bootc-image-builder:latest \
--type anaconda-iso \
--config /config.toml \
"$REGISTRY/$REGISTRY_USER/rhel9-bootc-workstation:latest"

```