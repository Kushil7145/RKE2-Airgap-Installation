#!/bin/bash

requirements_file="requirements.json"

# Check if the requirements.json file exists
if [[ ! -f "$requirements_file" ]]; then
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

# Copy artifacts to all master nodes
for master in $masters; do
  master_username=$(echo $master | jq -r '.username')
  master_ip=$(echo $master | jq -r '.ip')
  scp RKE2_Package.tar.gz "${master_username}@${master_ip}:/tmp/RKE2_Package.tar.gz"
done

# Copy artifacts to all worker nodes
for worker in $workers; do
  worker_username=$(echo $worker | jq -r '.username')
  worker_ip=$(echo $worker | jq -r '.ip')
  scp RKE2_Package.tar.gz "${worker_username}@${worker_ip}:/tmp/RKE2_Package.tar.gz"
done

echo "Completed copying the artifacts to the required servers"