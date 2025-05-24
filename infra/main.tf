data "http" "microos_checksum" {
  url = var.image_download_config.checksum_url
}

resource "proxmox_virtual_environment_download_file" "microos_image" {
  for_each           = var.available_nodes
  content_type       = var.image_download_config.content_type
  datastore_id       = var.image_download_config.datastore_id
  node_name          = each.key
  url                = var.image_download_config.url
  checksum           = local.checksum
  checksum_algorithm = var.image_download_config.checksum_algorithm
  file_name          = var.image_download_config.file_name
  overwrite          = var.image_download_config.overwrite
}

# Generate random minuite
resource "random_shuffle" "random_minutes" {
  for_each = local.all_vms
  input    = var.cloud_init_config.template.minute_offsets
  keepers = { # Avoid each time regenerate
    vm_key  = each.key
    vm_type = each.value.type
  }
}

resource "proxmox_virtual_environment_file" "controlplane_cloud_config" {
  for_each     = var.vms.controlplane.nodes
  content_type = "snippets"
  datastore_id = var.cloud_init_config.datastore_id
  node_name    = values(var.available_nodes)[index(keys(var.vms.controlplane.nodes), each.key) % length(var.available_nodes)]
  source_raw {
    data = templatefile("${path.module}/templates/cloud-init/user-data.tmpl", {
      hostname          = each.value
      ssh_public_key    = var.cloud_init_config.template.ssh_public_key
      hashed_password   = var.cloud_init_config.template.hashed_password
      packages          = var.cloud_init_config.template.packages
      extra_packages    = var.rke2_cloud_init_extra_packages
      reboot_window     = local.reboot_window[each.key]
      window_duration   = var.cloud_init_config.template.window_duration
      reboot_strategy   = var.cloud_init_config.template.reboot_strategy.rke2_nodes
      disable_rebootmgr = var.cloud_init_config.template.disable_rebootmgr.rke2_nodes
      change_repo       = var.cloud_init_config.template.change_repo
      repo_domain       = var.cloud_init_config.template.repo_domain
    })
    file_name = "${each.value}-user-data"
  }
}

resource "proxmox_virtual_environment_file" "worker_cloud_config" {
  for_each     = try(var.vms.worker.nodes, {})
  content_type = "snippets"
  datastore_id = var.cloud_init_config.datastore_id
  node_name    = values(var.available_nodes)[index(keys(var.vms.worker.nodes), each.key) % length(var.available_nodes)]
  source_raw {
    data = templatefile("${path.module}/templates/cloud-init/user-data.tmpl", {
      hostname          = each.value
      ssh_public_key    = var.cloud_init_config.template.ssh_public_key
      hashed_password   = var.cloud_init_config.template.hashed_password
      packages          = var.cloud_init_config.template.packages
      extra_packages    = var.rke2_cloud_init_extra_packages
      reboot_window     = local.reboot_window[each.key]
      window_duration   = var.cloud_init_config.template.window_duration
      reboot_strategy   = var.cloud_init_config.template.reboot_strategy.rke2_nodes
      disable_rebootmgr = var.cloud_init_config.template.disable_rebootmgr.rke2_nodes
      change_repo       = var.cloud_init_config.template.change_repo
      repo_domain       = var.cloud_init_config.template.repo_domain
    })
    file_name = "${each.value}-user-data"
  }
}

resource "proxmox_virtual_environment_file" "loadbalancer_cloud_config" {
  for_each     = var.vms.loadbalancer.nodes
  content_type = "snippets"
  datastore_id = var.cloud_init_config.datastore_id
  node_name    = values(var.available_nodes)[index(keys(var.vms.loadbalancer.nodes), each.key) % length(var.available_nodes)]
  source_raw {
    data = templatefile("${path.module}/templates/cloud-init/user-data.tmpl", {
      hostname          = each.value
      ssh_public_key    = var.cloud_init_config.template.ssh_public_key
      hashed_password   = var.cloud_init_config.template.hashed_password
      packages          = var.cloud_init_config.template.packages
      extra_packages    = var.loadbalancer_cloud_init_extra_packages
      reboot_window     = local.reboot_window[each.key]
      window_duration   = var.cloud_init_config.template.window_duration
      reboot_strategy   = var.cloud_init_config.template.reboot_strategy.lb_nodes
      disable_rebootmgr = var.cloud_init_config.template.disable_rebootmgr.lb_nodes
      change_repo       = var.cloud_init_config.template.change_repo
      repo_domain       = var.cloud_init_config.template.repo_domain
    })
    file_name = "${each.value}-user-data"
  }
}

resource "proxmox_virtual_environment_file" "controlplane_network_config" {
  for_each     = var.vms.controlplane.nodes
  content_type = "snippets"
  datastore_id = var.cloud_init_config.datastore_id
  node_name    = values(var.available_nodes)[index(keys(var.vms.controlplane.nodes), each.key) % length(var.available_nodes)]
  source_raw {
    data = templatefile("${path.module}/templates/cloud-init/network-config.tmpl", {
      dns_servers = var.cloud_init_config.template.dns_servers
      network_configs = [
        for cfg in var.cloud_init_controlplane_network_config.network_configs : {
          interface = cfg.interface
          type      = try(cfg.type, "dhcp")
          ip_address = (try(cfg.type, "dhcp") == "static" && try(cfg.base_ip, null) != null) ? (
            cidrhost(
              "${cfg.base_ip}/${try(cfg.cidr_netmask, 24)}",
              index(keys(var.vms.controlplane.nodes), each.key) + try(cfg.offset, 0)
            )
          ) : null,
          cidr_netmask   = try(cfg.cidr_netmask, null),
          gateway        = try(cfg.gateway, null),
          dns_search     = try(cfg.dns_search, null),
          dns_nameserver = try(cfg.dns_nameserver, null)
        }
      ]
    })
    file_name = "${each.value}-network-config"
  }
}

resource "proxmox_virtual_environment_file" "worker_network_config" {
  for_each     = try(var.vms.worker.nodes, {})
  content_type = "snippets"
  datastore_id = var.cloud_init_config.datastore_id
  node_name    = values(var.available_nodes)[index(keys(var.vms.worker.nodes), each.key) % length(var.available_nodes)]
  source_raw {
    data = templatefile("${path.module}/templates/cloud-init/network-config.tmpl", {
      dns_servers = var.cloud_init_config.template.dns_servers
      network_configs = [
        for cfg in var.cloud_init_worker_network_config.network_configs : {
          interface = cfg.interface
          type      = try(cfg.type, "dhcp")
          ip_address = (try(cfg.type, "dhcp") == "static" && try(cfg.base_ip, null) != null) ? (
            cidrhost(
              "${cfg.base_ip}/${try(cfg.cidr_netmask, 24)}",
              index(keys(var.vms.worker.nodes), each.key) + try(cfg.offset, 0)
            )
          ) : null,
          cidr_netmask   = try(cfg.cidr_netmask, null),
          gateway        = try(cfg.gateway, null),
          dns_search     = try(cfg.dns_search, null)
          dns_nameserver = try(cfg.dns_nameserver, null)
        }
      ]
    })
    file_name = "${each.value}-network-config"
  }
}

resource "proxmox_virtual_environment_file" "loadbalancer_network_config" {
  for_each     = var.vms.loadbalancer.nodes
  content_type = "snippets"
  datastore_id = var.cloud_init_config.datastore_id
  node_name    = values(var.available_nodes)[index(keys(var.vms.loadbalancer.nodes), each.key) % length(var.available_nodes)]
  source_raw {
    data = templatefile("${path.module}/templates/cloud-init/network-config.tmpl", {
      dns_servers = var.cloud_init_config.template.dns_servers
      network_configs = [
        for cfg in var.cloud_init_loadbalancer_network_config.network_configs : {
          interface = cfg.interface
          type      = try(cfg.type, "dhcp")
          ip_address = (try(cfg.type, "dhcp") == "static" && try(cfg.base_ip, null) != null) ? (
            cidrhost(
              "${cfg.base_ip}/${try(cfg.cidr_netmask, 24)}",
              index(keys(var.vms.loadbalancer.nodes), each.key) + try(cfg.offset, 0)
            )
          ) : null,
          cidr_netmask   = try(cfg.cidr_netmask, null),
          gateway        = try(cfg.gateway, null),
          dns_search     = try(cfg.dns_search, null)
          dns_nameserver = try(cfg.dns_nameserver, null)
        }
      ]
    })
    file_name = "${each.value}-network-config"
  }
}

resource "proxmox_virtual_environment_vm" "controlplane_vm" {
  for_each        = var.vms.controlplane.nodes
  name            = each.value
  node_name       = values(var.available_nodes)[index(keys(var.vms.controlplane.nodes), each.key) % length(var.available_nodes)]
  stop_on_destroy = var.controlplane_vm_config.stop_on_destroy
  vm_id           = var.controlplane_vm_config.vm_id_start + index(keys(var.vms.controlplane.nodes), each.key)
  pool_id         = var.controlplane_vm_config.pool_id
  # template = true
  agent {
    enabled = var.controlplane_vm_config.qemu_agent_enabled
  }
  cpu {
    cores = var.controlplane_vm_config.cpu_cores
    type  = var.controlplane_vm_config.cpu_type
  }
  memory {
    dedicated = var.controlplane_vm_config.mem_dedicated
    floating  = var.controlplane_vm_config.mem_floating
  }
  disk {
    datastore_id = var.controlplane_vm_config.disk_datastore
    file_id      = proxmox_virtual_environment_download_file.microos_image[keys(var.available_nodes)[index(keys(var.vms.controlplane.nodes), each.key) % length(var.available_nodes)]].id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.controlplane_vm_config.disk_size
  }
  dynamic "network_device" {
    for_each = var.controlplane_vm_config.network_devices
    content {
      bridge   = network_device.value["bridge"]
      model    = lookup(network_device.value, "model", "virtio")
      vlan_id  = lookup(network_device.value, "vlan_id", null)
      mtu      = lookup(network_device.value, "mtu", null)
      firewall = lookup(network_device.value, "firewall", false)
    }
  }
  # cdrom {
  #   file_id = "local:iso/ignition.iso"
  # }
  initialization {
    datastore_id         = var.cloud_init_config.datastore_id
    user_data_file_id    = proxmox_virtual_environment_file.controlplane_cloud_config[each.key].id
    network_data_file_id = proxmox_virtual_environment_file.controlplane_network_config[each.key].id
  }
}

resource "proxmox_virtual_environment_vm" "worker_vm" {
  for_each        = try(var.vms.worker.nodes, {})
  name            = each.value
  node_name       = values(var.available_nodes)[index(keys(var.vms.worker.nodes), each.key) % length(var.available_nodes)]
  stop_on_destroy = var.worker_vm_config.stop_on_destroy
  vm_id           = var.worker_vm_config.vm_id_start + index(keys(var.vms.worker.nodes), each.key)
  pool_id         = var.worker_vm_config.pool_id
  # template = true
  agent {
    enabled = var.worker_vm_config.qemu_agent_enabled
  }
  cpu {
    cores = var.worker_vm_config.cpu_cores
    type  = var.worker_vm_config.cpu_type
  }
  memory {
    dedicated = var.worker_vm_config.mem_dedicated
    floating  = var.worker_vm_config.mem_floating
  }
  disk {
    datastore_id = var.worker_vm_config.disk_datastore
    file_id      = proxmox_virtual_environment_download_file.microos_image[keys(var.available_nodes)[index(keys(var.vms.worker.nodes), each.key) % length(var.available_nodes)]].id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.worker_vm_config.disk_size
  }
  dynamic "network_device" {
    for_each = var.worker_vm_config.network_devices
    content {
      bridge   = network_device.value["bridge"]
      model    = lookup(network_device.value, "model", "virtio")
      vlan_id  = lookup(network_device.value, "vlan_id", null)
      mtu      = lookup(network_device.value, "mtu", null)
      firewall = lookup(network_device.value, "firewall", false)
    }
  }
  # cdrom {
  #   file_id = "local:iso/ignition.iso"
  # }
  initialization {
    datastore_id         = var.cloud_init_config.datastore_id
    user_data_file_id    = proxmox_virtual_environment_file.worker_cloud_config[each.key].id
    network_data_file_id = proxmox_virtual_environment_file.worker_network_config[each.key].id
  }
}

resource "proxmox_virtual_environment_vm" "loadbalancer_vm" {
  for_each        = try(var.vms.loadbalancer.nodes, {})
  name            = each.value
  node_name       = values(var.available_nodes)[index(keys(var.vms.loadbalancer.nodes), each.key) % length(var.available_nodes)]
  stop_on_destroy = var.loadbalancer_vm_config.stop_on_destroy
  vm_id           = var.loadbalancer_vm_config.vm_id_start + index(keys(var.vms.loadbalancer.nodes), each.key)
  pool_id         = var.loadbalancer_vm_config.pool_id
  # template = true
  agent {
    enabled = var.loadbalancer_vm_config.qemu_agent_enabled
  }
  cpu {
    cores = var.loadbalancer_vm_config.cpu_cores
    type  = var.loadbalancer_vm_config.cpu_type
  }
  memory {
    dedicated = var.loadbalancer_vm_config.mem_dedicated
    floating  = var.loadbalancer_vm_config.mem_floating
  }
  disk {
    datastore_id = var.loadbalancer_vm_config.disk_datastore
    file_id      = proxmox_virtual_environment_download_file.microos_image[keys(var.available_nodes)[index(keys(var.vms.loadbalancer.nodes), each.key) % length(var.available_nodes)]].id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.loadbalancer_vm_config.disk_size
  }
  dynamic "network_device" {
    for_each = var.loadbalancer_vm_config.network_devices
    content {
      bridge   = network_device.value["bridge"]
      model    = lookup(network_device.value, "model", "virtio")
      vlan_id  = lookup(network_device.value, "vlan_id", null)
      mtu      = lookup(network_device.value, "mtu", null)
      firewall = lookup(network_device.value, "firewall", false)
    }
  }
  # cdrom {
  #   file_id = "local:iso/ignition.iso"
  # }
  initialization {
    datastore_id         = var.cloud_init_config.datastore_id
    user_data_file_id    = proxmox_virtual_environment_file.loadbalancer_cloud_config[each.key].id
    network_data_file_id = proxmox_virtual_environment_file.loadbalancer_network_config[each.key].id
  }
}

resource "local_file" "ansible_inventory" {
  filename             = "${path.module}/inventory.gen"
  directory_permission = "0755"
  file_permission      = "0644"
  content = templatefile("${path.module}/templates/ansible/inventory.tmpl", {
    vms = var.vms
  })
}
