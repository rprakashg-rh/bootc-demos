# boot-demos
This repository contains all bootc demos. Images directory contains various bootc examples that can be used for demonstration


## Building Images Locally using Podman Cli
Before building the image from your local machine using podman cli be sure to signin to Redhat

Build container image by running command below

```sh
podman build --secret id=creds,src=$HOME/.config/containers/auth.json -f images/workstation/Containerfile -t quay.io/rgopinat/rhel9-bootc-workstation
```

## Create ISO
First build the makeiso container by running command below

```sh
podman build -f makeiso/Containerfile -t quay.io/rgopinat/makeiso:latest
```

push the container to registry

```sh
podman push quay.io/rgopinat/makeiso:latest
```

```sh
podman run --rm \
    -v $HOME/.config/containers/auth.json:/root/.config/containers/auth.json \
    -v $PWD/ks:/ks \
    -v $HOME/iso:/iso \
    -v $PWD/output:/output \
    -it \
    quay.io/rgopinat/makeiso:latest ./create-iso.sh quay.io/rgopinat/rhel9-bootc-workstation workstation.ks rhel-9.5-x86_64-boot.iso installer.iso
```

## Create AMI

