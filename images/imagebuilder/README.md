# Image Builder

Build Image 

```sh
podman build --secret id=creds,src=$HOME/.config/containers/auth.json \
    --authfile=$PULL_SECRET \
    -t "$REGISTRY/$REGISTRY_USER/imagebuilder-bootc" \
    -f Containerfile .
```

Inject pullsecret, start, adding sources to osbuild and starting osbuild services through cloud-init or anaconda kickstart
