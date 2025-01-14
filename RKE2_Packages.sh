#!/bin/bash

usage(){
  echo "Need one argument to the script $0 "
  echo "Example: sh $0 v1.26.10+rke2r2 "
  exit 1
}
# Check if one argument is present
if [ $# -ne 1 ]; then
  usage
fi

version=$1
encoded_version=$(printf '%s' "$version" | jq -sRr '@uri')

# Create an directory for Packaging
mkdir RKE2_Package

# Downloading the packages for RKE2
curl -L https://github.com/rancher/rke2/releases/download/"${encoded_version}"/rke2-images.linux-amd64.tar.zst -o RKE2_Package/rke2-images.linux-amd64.tar.zst
curl -L https://github.com/rancher/rke2/releases/download/"${encoded_version}"/rke2.linux-amd64.tar.gz -o RKE2_Package/rke2.linux-amd64.tar.gz
curl -L https://github.com/rancher/rke2/releases/download/"${encoded_version}"/sha256sum-amd64.txt -o RKE2_Package/sha256sum-amd64.txt
curl -sfL https://get.rke2.io --output RKE2_Package/install.sh

# Create a tarball of the RKE2_Package directory
tar -czvf RKE2_Package.tar.gz RKE2_Package