#!/bin/bash

requirements_file="requirements.json"

# Check if the requirements.json file exists
if [ ! -f "$requirements_file" ]; then
  echo "The file $requirements_file does not exist."
  exit 1
fi

# Read the JSON file using jq and store values in variables
RKE2_version=$(jq -r '.RKE2_version' $requirements_file)
masters=$(jq -c '.masters[]' $requirements_file)
workers=$(jq -c '.workers[]' $requirements_file)

# Print values to verify
echo "RKE2_version: $RKE2_version"
echo "Masters: $masters"
echo "Workers: $workers"

# Install artifacts on all master nodes
for master in $masters; do
  master_username=$(echo "$master" | jq -r '.username')
  master_ip=$(echo "$master" | jq -r '.ip')
  ssh -t "${master_username}@${master_ip}" "sudo bash -s" <<EOF
    echo "Entered into ${master_username} ......"
    sudo mkdir -p /root/rke2-artifacts
    sudo cp /tmp/RKE2_Package.tar.gz /root/rke2-artifacts/
    cd /root/rke2-artifacts
    sudo tar -xzvf /root/rke2-artifacts/RKE2_Package.tar.gz
    cd RKE2_Package
    INSTALL_RKE2_ARTIFACT_PATH=/root/rke2-artifacts/RKE2_Package/ sh install.sh
    mkdir -p /var/lib/rancher/rke2/agent/images/
    sudo cp /root/rke2-artifacts/RKE2_Package/rke2-images.linux-amd64.tar.zst /var/lib/rancher/rke2/agent/images/
    sudo systemctl enable rke2-server.service
    sudo systemctl start rke2-server.service
EOF
done

master1_name=$(echo "$masters" | jq -r '.username')
master1_ip=$(echo "$masters" | jq -r '.ip')
token=$(ssh "${master1_name}@${master1_ip}" "sudo cat /var/lib/rancher/rke2/server/node-token")

# Copy artifacts to all worker nodes
for worker in $workers; do
  worker_username=$(echo "$worker" | jq -r '.username')
  worker_ip=$(echo "$worker" | jq -r '.ip')
  ssh -t "${worker_username}@${worker_ip}" "sudo bash -s" <<EOF
    echo "Entered into ${worker_username} ......"
    sudo mkdir -p /root/rke2-artifacts
    sudo cp /tmp/RKE2_Package.tar.gz /root/rke2-artifacts/
    cd /root/rke2-artifacts/
    sudo tar -xzvf /root/rke2-artifacts/RKE2_Package.tar.gz
    cd RKE2_Package
    INSTALL_RKE2_ARTIFACT_PATH=/root/rke2-artifacts/RKE2_Package INSTALL_RKE2_TYPE="agent" sh install.sh
    mkdir -p /var/lib/rancher/rke2/agent/images/
    sudo cp /root/rke2-artifacts/RKE2_Package/rke2-images.linux-amd64.tar.zst /var/lib/rancher/rke2/agent/images/
    sudo mkdir -p /etc/rancher/rke2/
    sudo tee /etc/rancher/rke2/config.yaml > /dev/null <<EOL
server: "https://${master1_ip}:9345"
token: "${token}"
EOL
    sudo systemctl enable rke2-agent.service
    sudo systemctl start rke2-agent.service
EOF
done