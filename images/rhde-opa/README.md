# Red Hat Device Edge with Open Policy Agent

Set some environment variables

```sh
export RHDE_OPA_IMAGE=rhde-opa
export TAG=1.0
export REGISTRY=quay.io
export REGISTRY_USER=rgopinat
export ADMIN_USER_PASSWORD=<redacted>
export PULL_SECRET=$HOME/rhpullsecret/pull-secret.txt
```

```sh
sudo podman build \
    --secret id=creds,src=$HOME/.config/containers/auth.json \
    --authfile=$PULL_SECRET -t "$REGISTRY/$REGISTRY_USER/$RHDE_OPA_IMAGE:$TAG" \
    --build-arg=ADMIN_USER_PASSWORD=${ADMIN_USER_PASSWORD} \
    -f Containerfile .
```
