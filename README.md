# Starbase Cluster - Automated RKE2 Deployment on Proxmox VE

[![GitHub License](https://img.shields.io/github/license/vnwnv/starbase-cluster-k8s?style=flat-square&color=blue)
](https://www.gnu.org/licenses/agpl-3.0.en.html)
[![GitHub Release](https://img.shields.io/github/v/release/vnwnv/starbase-cluster-k8s?include_prereleases&style=flat-square&color=brightgreen)](https://github.com/vnwnv/starbase-cluster-k8s/releases)

Starbase cluster based on:

[![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=flat-square&logo=ansible&logoColor=white)](https://ansible.com)
[![Static Badge](https://img.shields.io/badge/ProxmoxVE-%23E57000?style=flat-square&logo=proxmox&logoColor=white)](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview)
[![openSUSE MicroOS](https://img.shields.io/badge/opsnSUSE%20MicroOS-73BA25?style=flat-square&logo=openSUSE&logoColor=white)](https://ansible.com)
[![Terraform](https://img.shields.io/badge/HashiCorp%20Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)](https://terraform.io)

**Easy RKE2 Cluster Deployment** - Automate your Kubernetes infrastructure lifecycle on Proxmox VE with Terraform and Ansible.

Full document site [vnwnv.github.io/starbase-cluster-website](https://vnwnv.github.io/starbase-cluster-website/) is in comming, documents will publish to there.

## 🎞️ Context

- This project is for the people who want to use kubernetes cluster on their self-host ProxmoxVE platform.
- This project aims to give you an opportunity to use kubernetes instead of docker-compose to manage your self-hosted applications/websites by simplify the creation and maintenance of the kubernetes cluster.
- This project is also good for a team, which do not have their datacenter and do not have enough members to operate and maintain a big cluster but want to deploy applications on local kubernetes cluster.

## 🚀 Key Features

### Infrastructure Automation

- **Proxmox VE Integration**: Deploy virtual machines with precise network/hardware configurations through [bpg/proxmox](https://github.com/bpg/terraform-provider-proxmox) Terraform provider
- **Auto VM Assignment**: Auto assign kubernetes VMs to **all of ProxmoxVE nodes** by poll mechanism
- **Multi-Role Architecture**: Auto provision control planes, workers, and load balancers with **distinct IP allocation strategies** support
- **Immutable OS Foundation**: Built on [openSUSE MicroOS](https://microos.opensuse.org/) for automatic **atomic updates** and **automatic transactional rollbacks**
- **HA RKE2 Controlplane**: Auto deploy HAProxy + Keepalived implementation with virtual IP failover (VRRP) to make a **high availability controlplane**
- **Multiple Networking**: Pre-configured Canal CNI with support for Network Policies and can be change to others

### Operational Excellence

- **Custom Repo Mirror**: Built-in support for change openSUSE mirror site (plan to support air gap installation)
- **Security Baseline**: SELinux enforcement, SSH key authentication etc

## 📦 Quick Start

This project is divided into two components: Terraform and Ansible.

During the design phase, we deliberately avoided using any Terraform provisioners to ensure compatibility across diverse environments. And you can also insert some operation between VM and Kubernetes deployment. 

As a result, deploying the cluster requires **two** primary steps.

### Prerequisites

- Proxmox VE cluster/node with API access
- Terraform and Ansible installed
- Network segments pre-configured in Proxmox

### Deployment Workflow

```bash
# 1. Clone repository
git clone https://github.com/vnwnv/starbase-cluster-k8s.git
cd starbase-cluster/infra

# 2. Prepare Terraform configuration
cp vars/tfvars.example your-cluster-terraform.tfvars

# 3. Initialize Terraform
terraform init

# 4. Deploy infrastructure
terraform apply

# 5. Prepare Ansible configuration
cd bootstarp
cp tools_playbook/* ./

# 6. Deploy cluster by the auto-generated inventory and default values
cp ../infra/inventory.gen ./
ansible-playbook -i inventory.gen deploy.playbook.yml

# 7. Deploy kured for node auto reboot
helm repo add kubereboot https://kubereboot.github.io/charts
helm install my-release kubereboot/kured --values values.yaml
```

## 🔧 Configuration Guide

**Be careful**: when you need edit a value in an object, you **MUST** provide all other values in same object! Otherwise, remain the values will be overrided with `null` value.

The document is still work in progress. More documents will be added in the feature.

### Terraform (`terraform.tfvars`)

There is a [full config example tfvar file with comment](./infra/vars/tfvars.example). follow that file to create your custom tfvar file.

### Ansible (`vars file`)

There is a [minimal ansible value file](./bootstrap/tools_playbook/vars/custom.yml). And also [a document](./bootstrap/deploy_rke2/vars.md) explains all of variables.

### Auto Reboot

The openSUSE MicroOS may need reboot after auto upgrade. The loadbalancer node can be auto reboot. To reduce accidental interruption, the others deployed with auto reboot disabled.

You can reboot the node manually. But There is a more gentle way to do this by using [kured (Kubernetes Reboot Daemon)](https://github.com/kubereboot/kured) to handle reboot. The ArgoCD file install kured by using helm chart is in the charts folder. You can find helm values in that file. All of the nodes will use UTC time zone, you may need calculate about reboot time window.

## Todo List

This project plan to support these features:

- [ ] Other Linux distributions
- [ ] More documents and tutorials
- [ ] Air gap deployment

## 🤝 Contribution Guidelines

1. Fork the repository and create feature branch
2. Validate changes with Terraform validate and Ansible lint
3. Update documentation for new configuration parameters
4. Submit PR with detailed change description

📜 **License**: All of components in this repository are under [GNU Affero General Public License version 3 (AGPLv3)](https://www.gnu.org/licenses/agpl-3.0.en.html)
