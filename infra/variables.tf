variable "cloud_init_config" {
  type = object({
    datastore_id = string
    template = object({
      dns_servers     = list(string)
      ssh_public_key  = string
      hashed_password = string
      packages        = list(string)
      window_duration = string
      reboot_slots    = list(number)
      minute_offsets  = list(number)
      reboot_strategy = object({
        rke2_nodes = string
        lb_nodes   = string
      })
      change_repo = bool
      repo_domain = string
      disable_rebootmgr = object({
        rke2_nodes = string
        lb_nodes   = string
      })
    })
  })
  default = {
    datastore_id = "local"
    template = {
      dns_servers     = [""]
      ssh_public_key  = ""
      hashed_password = ""
      packages        = ["qemu-guest-agent", "screen", "htop", "policycoreutils-python-utils"]
      window_duration = "1h"
      reboot_slots    = [17, 18, 19, 20, 21, 22] # hour in 24 format
      minute_offsets  = [0, 15, 30, 45]          # minute
      reboot_strategy = {
        rke2_nodes = "best-effort"
        lb_nodes   = "best-effort"
      }
      change_repo = false
      repo_domain = "https://mirrors.bfsu.edu.cn/opensuse"
      disable_rebootmgr = {
        rke2_nodes = true
        lb_nodes   = false
      }
    }
  }
  description = "Cloud-init config-object"
}

variable "cloud_init_controlplane_network_config" {
  type = object({
    network_configs = optional(list(object({
      interface     = string
      base_ip       = optional(string)
      gateway       = optional(string)
      type          = optional(string)
      cidr_netmask  = optional(number)
      offset        = optional(number)
      dns_search    = optional(list(string))
      dns_nameserver = optional(list(string))
    })))
  })
  default = {
    network_configs = [
      {
        interface = "ens18"
        type      = "dhcp"
      }
    ]
  }
}

variable "cloud_init_worker_network_config" {
  type = object({
    network_configs = optional(list(object({
      interface     = string
      base_ip       = optional(string)
      gateway       = optional(string)
      type          = optional(string)
      cidr_netmask  = optional(number)
      offset        = optional(number)
      dns_search    = optional(list(string))
      dns_nameserver = optional(list(string))
    })))
  })
  default = {
    network_configs = [
      {
        interface = "ens18"
        type      = "dhcp"
      }
    ]
  }
}

variable "cloud_init_loadbalancer_network_config" {
  type = object({
    network_configs = optional(list(object({
      interface     = string
      base_ip       = optional(string)
      gateway       = optional(string)
      type          = optional(string)
      cidr_netmask  = optional(number)
      offset        = optional(number)
      dns_search    = optional(list(string))
      dns_nameserver = optional(list(string))
    })))
  })
  default = {
    network_configs = [
      {
        interface = "ens18"
        type      = "dhcp"
      }
    ]
  }
}

variable "cloud_provider" {
  type = object({
    endpoint  = string
    api_token = string
    insecure  = bool
    ssh = object({
      agent       = bool
      username    = string
      private_key = string
    })
  })
  sensitive = true
}

variable "image_download_config" {
  type = object({
    content_type       = string
    datastore_id       = string
    url                = string
    file_name          = string
    overwrite          = bool
    checksum_url       = string
    checksum_algorithm = string
  })
  default = {
    content_type       = "iso"
    datastore_id       = "local"
    url                = "https://download.opensuse.org/tumbleweed/appliances/openSUSE-MicroOS.x86_64-OpenStack-Cloud.qcow2"
    file_name          = "openSUSE-MicroOS.x86_64-kvm-and-xen.img"
    overwrite          = true
    checksum_url       = "https://download.opensuse.org/tumbleweed/appliances/openSUSE-MicroOS.x86_64-OpenStack-Cloud.qcow2.sha256"
    checksum_algorithm = "sha256"
  }
  description = "cloud-init prebuilt OS image config"
}

variable "vms" {
  type = map(object({
    nodes = map(string)
  }))
  default = {
    controlplane = {
      nodes = {
        "control0" = "ktest0.lan"
        "control1" = "ktest1.lan"
        "control2" = "ktest2.lan"
      }
    }
    loadbalancer = {
      nodes = {
        "lb0" = "kload0.lan"
        "lb1" = "kload1.lan"
      }
    }
    worker = null
  }
  description = "Map of VM types (controlplane/worker/loadbalancer) and their VMs"
}

variable "controlplane_vm_config" {
  type = object({
    stop_on_destroy = bool
    vm_id_start     = number # VM ID
    pool_id         = string
    cpu_cores       = number
    cpu_type        = string
    mem_dedicated   = number # MB
    mem_floating    = number # MB
    disk_size       = number # GB
    disk_datastore  = string
    network_devices = list(object({
      bridge   = string
      model    = optional(string, "virtio")
      vlan_id  = optional(number)
      mtu      = optional(number)
      firewall = optional(bool, false)
    }))
    qemu_agent_enabled = bool
  })
  default = {
    # should be true if qemu agent is not installed / enabled on the VM
    stop_on_destroy = true
    vm_id_start     = 210
    pool_id         = ""
    cpu_cores       = 2
    cpu_type        = "x86-64-v2-AES"
    mem_dedicated   = 2048
    mem_floating    = 2048
    disk_size       = 50
    disk_datastore  = "local"
    network_devices = [
      {
        bridge = "vmbr1_210"
      }
    ]

    qemu_agent_enabled = true
  }
  description = "VM config of control plane"
}

variable "worker_vm_config" {
  type = object({
    stop_on_destroy = bool
    vm_id_start     = number # VM ID
    pool_id         = string
    cpu_cores       = number
    cpu_type        = string
    mem_dedicated   = number # MB
    mem_floating    = number # MB
    disk_size       = number # GB
    disk_datastore  = string
    network_devices = list(object({
      bridge   = string
      model    = optional(string, "virtio")
      vlan_id  = optional(number)
      mtu      = optional(number)
      firewall = optional(bool, false)
    }))
    qemu_agent_enabled = bool
  })
  default = {
    # should be true if qemu agent is not installed / enabled on the VM
    stop_on_destroy = true
    vm_id_start     = 220
    pool_id         = ""
    cpu_cores       = 2
    cpu_type        = "x86-64-v2-AES"
    mem_dedicated   = 2048
    mem_floating    = 2048
    disk_size       = 50
    disk_datastore  = "local"
    network_devices = [
      {
        bridge = "vmbr1_210"
      }
    ]
    qemu_agent_enabled = true
  }
  description = "VM config of control plane"
}

variable "loadbalancer_vm_config" {
  type = object({
    stop_on_destroy = bool
    vm_id_start     = number # VM ID
    pool_id         = string
    cpu_cores       = number
    cpu_type        = string
    mem_dedicated   = number # MB
    mem_floating    = number # MB
    disk_size       = number # GB
    disk_datastore  = string
    network_devices = list(object({
      bridge   = string
      model    = optional(string, "virtio")
      vlan_id  = optional(number)
      mtu      = optional(number)
      firewall = optional(bool, false)
    }))
    qemu_agent_enabled = bool
  })
  default = {
    # should be true if qemu agent is not installed / enabled on the VM
    stop_on_destroy = true
    vm_id_start     = 200
    pool_id         = ""
    cpu_cores       = 2
    cpu_type        = "x86-64-v2-AES"
    mem_dedicated   = 2048
    mem_floating    = 2048
    disk_size       = 50
    disk_datastore  = "local"
    network_devices = [
      {
        bridge = "vmbr1_210"
      }
    ]
    qemu_agent_enabled = true
  }
  description = "VM config of control plane"
}

variable "available_nodes" {
  type        = map(string)
  description = "List of available Proxmox nodes for VM deployment"
  default = {
    storage0-pve = "storage0-pve"
  }
}

variable "rke2_cloud_init_extra_packages" {
  type    = list(string)
  default = ["rke2", "rke2-selinux"]
}

variable "loadbalancer_cloud_init_extra_packages" {
  type    = list(string)
  default = ["haproxy", "keepalived"]
}
