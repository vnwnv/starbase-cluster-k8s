locals {
  checksum = try(
    split(" ", data.http.microos_checksum.response_body)[0],
    regex("^[0-9a-f]{64}", data.http.microos_checksum.response_body)
  )
  vm_types = keys(var.vms)

  # translate to { "vm_name": { type, vm, fqdn } } structure from var.vms 
  all_vms = merge(
    [for vm_type, config in var.vms :
      {
        for vm_name, fqdn in config.nodes :
        vm_name => {
          type = vm_type,
          fqdn = fqdn
        }
      }
      if config != null
    ]...
  )

  vm_random_minutes = {
    for key, attr in local.all_vms :
    key => random_shuffle.random_minutes[key].result[0]
  }

  reboot_window = {
    for key, attr in local.all_vms :
    key => format("%02d:%02d",
      var.cloud_init_config.template.reboot_slots[
        index(keys(local.all_vms), key) % length(var.cloud_init_config.template.reboot_slots)
      ],
      local.vm_random_minutes[key]
    )
  }
}
