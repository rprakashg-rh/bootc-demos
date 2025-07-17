# Bootc Image with RHEM pre-installed

## Building Container Image
Build image mode container image

```sh
podman build --secret id=creds,src=$HOME/.config/containers/auth.json \
    --authfile=$PULL_SECRET \
    -t "$REGISTRY/$REGISTRY_USER/rhem-server" \
    -f Containerfile .
```

## Push to registry
Push the container image to registry

```sh
podman push "$REGISTRY/$REGISTRY_USER/rhem-server"
```

## Build AMI
Build AMI to test in AWS

### Overlay cloud-init
Overlay cloud init packages. 

First switch to cloud-init directory under images

```sh
cd images/cloud-init
```

then run podman build to build a new image with aws tag

```sh
podman build \
--build-arg=FROM=$REGISTRY/$REGISTRY_USER/rhem-server \
-t $REGISTRY/$REGISTRY_USER/rhem-server:aws \
-f Containerfile .
```

### Build the AMI using BiB
Build the AMI image using Bootc Image Builder

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
--aws-ami-name rhem-server-x86_64 \
--aws-bucket bootc-amis \
--aws-region us-west-2 \
$REGISTRY/$REGISTRY_USER/rhem-server:aws
```

## Testing in AWS
If you do not have a VPC in your AWS account run the terraform scripts in `terraform/vpc` directory to create a VPC in AWS

```sh
cd terraform/vpc

terraform init
terraform plan
terraform apply
```

Note down the public subnet id and the security group id associated with public subnet and update the `rhem-server.yml` vars file, additionally also update the AMI ID 

Run ansible playbook to launch a new ec2 instance

```sh
ansible-playbook --vault-password-file <(echo "$VAULT_SECRET") launch-ec2.yaml -e @vars/rhem-server.yml
```

