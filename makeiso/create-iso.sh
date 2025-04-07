#!/bin/bash

set -e

if [ "$#" -ne 4 ]; then
    echo This script takes precisely 4 arguments:
    echo "  - container image to be embedded in iso"
    echo "  - path to kickstart file to be embedded in iso"
    echo "  - path to original iso"
    echo "  - new iso"
    exit 1
fi

if [ ! -f "/ks/$2" ]; then
    echo Cannot find "$2" kickstart file in /ks, please check your paths.
    exit 1
fi

if [ ! -f "/iso/$3" ]; then
    echo Cannot find "$3" as the starting iso
    echo You can download RHEL 9.4 iso from https://developers.redhat.com/products/rhel/download
    echo or CentOS Stream 9 from https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-20240422.0-x86_64-boot.iso
    exit 1
fi

TEMPDIR=$(mktemp --directory)

echo "Copying kickstart file $2 to ${TEMPDIR}"
cp "/ks/$2" "${TEMPDIR}/$2"

echo "Unpacking the container image"
mkdir -p "${TEMPDIR}/container"

# be sure to mount the auth.json if image is in private registry
skopeo copy --authfile ~/.config/containers/auth.json "docker://$1" "oci:${TEMPDIR}/container/"

cd "${TEMPDIR}"
mkksiso --ks $2 --add container/ \
    --cmdline "console=tty0 console=ttyS0,115200n8" \
    "/iso/$3" "/output/$4"
