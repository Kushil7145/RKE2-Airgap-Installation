# RKE2 Air-Gapped Installation

## Overview
This repository provides a step-by-step guide for installing RKE2 in an air-gapped environment using the tarball method. The setup requires a **Build Server** with internet access and an **RKE2 Cluster** that has no internet access but allows passwordless SSH access between its nodes. Packages will be downloaded on the Build Server and transferred to the cluster for installation.

## Prerequisites
- A Build Server with internet access.
- A cluster with no internet access but with passwordless SSH access between nodes.
- Properly configured `requirements.json` file with cluster details.

## Steps to Download Packages on the Build Server
1. Clone this repository into the Build Server:
   ```sh
   git clone https://github.com/Kushil7145/RKE2-Airgap-Installation.git
   cd RKE2-Airgap-Installation
   ```
2. Run the `RKE2_Packages.sh` script with the required RKE2 version as an argument.
   - You can find available RKE2 versions [here](https://github.com/rancher/rke2/releases).
   - Example command:
     ```sh
     ./RKE2_Packages.sh v1.32.1+rke2r1
     ```
3. The necessary packages will be downloaded and prepared for transfer to the air-gapped cluster.

## Steps to Copy and Install Packages in the Cluster
1. Open the `requirements.json` file and provide the necessary details of the cluster.
2. Run the `RKE2_artifacts_copy.sh` script on the Build Server. This will transfer the required packages to the cluster nodes based on the configuration in `requirements.json`.
   ```sh
   ./RKE2_artifacts_copy.sh
   ```
3. On the **Master Node**, execute the `RKE2_setup.sh` script to install RKE2:
   ```sh
   ./RKE2_setup.sh
   ```
4. The RKE2 installation will now be completed in the air-gapped environment.

## License
This project is licensed under the MIT License. See the [LICENSE](https://github.com/Kushil7145/RKE2-Airgap-Installation/blob/main/LICENSE) file for details.

## Contribution
Contributions are welcome! Please open an issue or submit a pull request for any improvements.

## Support
For any issues or queries, feel free to raise an issue in this repository or contact me.


