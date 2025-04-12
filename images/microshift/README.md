# Microshift bootc demo
Microshift bootc demo

## Build Image
Follow these steps to build microshift bootc images

Set some environment variables

```sh
export IMAGE_NAME=microshift-bootc
export TAG=1.0
export REGISTRY=quay.io
export REGISTRY_USER=rgopinat
export ADMIN_USER_PASSWORD=<redacted>
export PULL_SECRET=$HOME/rhpullsecret/pull-secret.txt
```

Build the image
```sh
cd images/microshift
sudo podman build \
    --secret id=creds,src=$HOME/.config/containers/auth.json \
    --authfile=$PULL_SECRET -t "$REGISTRY/$REGISTRY_USER/$IMAGE_NAME:$TAG" \
    --build-arg=ADMIN_USER_PASSWORD=$ADMIN_USER_PASSWORD \
    -f Containerfile .
```

Push the image to registry

```sh
sudo podman push "$REGISTRY/$REGISTRY_USER/$IMAGE_NAME:$TAG"
```

## Building anaconda iso

```sh
sudo podman pull "$REGISTRY/$REGISTRY_USER/$IMAGE_NAME:$TAG"

sudo podman run \
--authfile=$PULL_SECRET \
--rm \
--privileged \
--pull-newer \
--security-opt label=type:unconfined_t \
-v $PWD/images/microshift/config.toml:/config.toml:ro \
-v $PWD/output:/output \
-v /var/lib/containers/storage:/var/lib/containers/storage \
quay.io/centos-bootc/bootc-image-builder:latest \
--type anaconda-iso \
--config /config.toml \
"$REGISTRY/$REGISTRY_USER/$IMAGE_NAME:$TAG"
```
## Building AMI image for AWS
Follow steps in this section to build an AMI image for running virtualized devices on AWS

Set some environment variables

```sh
export AWS_IMAGE_NAME=microshift-bootc-aws
export AMI_BUCKET=bootc-amis
```

Create an S3 bucket to store AMI artifacts

```sh
aws s3api create-bucket \
    --bucket=${AMI_BUCKET} \
    --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION
```

Create VMImport Service Roles

```sh
aws iam create-role \
  --role-name=vmimport \
  --assume-role-policy-document='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "vmie.amazonaws.com"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "sts:Externalid": "vmimport"  
                }
            }
        }
    ]}' \
--query='Role.Arn' \
--output=text | pbcopy
```
Role Arn: `arn:aws:iam::695524278079:role/vmimport`

Create role policy

```sh
aws iam create-policy \
    --policy-name=vmimport_service_role_policy \
    --policy-document='{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action":  [
                    "s3:GetBucketLocation",
                    "s3:GetObject",
                    "s3:PutObject"
                ],
                "Resource": [
                    "arn:aws:s3:::bootc-amis",
                    "arn:aws:s3:::bootc-amis/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "s3:GetBucketLocation",
                    "s3:GetObject",
                    "s3:ListBucket",
                    "s3:PutObject",
                    "s3:GetBucketAcl"
                ],
                "Resource": [
                    "arn:aws:s3:::bootc-amis",
                    "arn:aws:s3:::bootc-amis/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "ec2:ModifySnapshotAttribute",
                    "ec2:CopySnapshot",
                    "ec2:RegisterImage",
                    "ec2:Describe*"
                ],
                "Resource": "*"
            }
        ]}' \
--query='Policy.Arn' \
--output=text | pbcopy
```

Attach the Policy to Role

```sh
aws iam attach-role-policy \
  --role-name=vmimport \
  --policy-arn=arn:aws:iam::695524278079:policy/vmimport_service_role_policy
```

Overlay base microshift image image with cloud-init

```sh
sudo podman build \
    --build-arg="FROM=quay.io/rgopinat/microshift-bootc:1.0" \
    -t "$REGISTRY/$REGISTRY_USER/$AWS_IMAGE_NAME:$TAG" \
    -f Containerfile .
```

Push to registry

```sh
podman push "$REGISTRY/$REGISTRY_USER/$AWS_IMAGE_NAME:$TAG"
```

Build AMI using bootc image builder

```sh
sudo podman run \
--authfile=$PULL_SECRET \
--rm \
--privileged \
--pull=newer \
--security-opt label=type:unconfined_t \
--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
--env AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} \
-v /var/lib/containers/storage:/var/lib/containers/storage \
registry.redhat.io/rhel9/bootc-image-builder:latest \
--type ami \
--aws-ami-name microshift-bootc-x86_64 \
--aws-bucket ${AMI_BUCKET} \
--aws-region us-west-2 \
"$REGISTRY/$REGISTRY_USER/$AWS_IMAGE_NAME:$TAG"
```

