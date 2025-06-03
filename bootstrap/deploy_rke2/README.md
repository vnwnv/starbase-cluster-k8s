deploy_rke2
=========

This Ansible role is designed to deploy RKE2 (Rancher Kubernetes Engine 2) on a cluster of nodes which based on openSUSE MicroOS. It handles the installation and configuration of RKE2, including setting up load balancers, configuring registries, and applying transactional updates.

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

The role is organized as follows:

```
bootstrap/deploy_rke2/
├── defaults/
│   └── main.yml       # Default variables
├── handlers/
│   └── main.yml       # Handlers for post-tasks
├── meta/
│   └── main.yml       # Metadata about the role
├── tasks/
│   ├── loadbalancer.playbook.yml  # Tasks for setting up load balancers
│   ├── main.yml                 # Main tasks file
│   ├── rke2_common.playbook.yml   # Common RKE2 tasks
│   ├── rke2_first.playbook.yml    # Tasks for the first node
│   ├── rke2_remain.playbook.yml   # Tasks for remaining nodes
│   └── transactional_apply.playbook.yml  # Tasks for applying transactional updates
├── templates/
│   ├── haproxy.cfg.j2           # Template for HAProxy configuration
│   ├── keepalived.conf.j2       # Template for Keepalived configuration
│   ├── rke2_config.yml.j2       # Template for RKE2 configuration
│   └── rke2_registries.yml.j2   # Template for RKE2 registries configuration
└── tests/
    ├── inventory                # Inventory file for testing
    └── test.yml                 # Test playbook
```

Role Variables
--------------

[vars.md](vars.md) list all variables.

There is a [custom.yml](../vars/custom.yml) include common config in parent directory. Maybe useful for customize.

Dependencies
------------

We need [`community.general` collection](https://galaxy.ansible.com/ui/repo/published/community/general/) to manipulate `zypper` and `transactional-update`

- To check whether it is installed, run `ansible-galaxy collection list`.
- To install it, use: `ansible-galaxy collection install community.general`

Example Playbook
----------------

these file can be find in parent directory

```yaml
---
- name: Test
  hosts: all
  vars_files:
    - vars/custom.yml
  roles:
    - deploy_rke2
```

The inventory file can be auto generate by Terraform.

When finished, you can find the kube config in `/tmp/kubeconfig.yaml`.

License
-------

MIT

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
